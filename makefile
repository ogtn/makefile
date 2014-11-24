# Voici un petit makefile à peu prêt générique.
# Bon, en fait, pas vraiment. Je m'explique.
#
# La liste des .c est à ajouter à la main, dans la variable EXE_SRC
# Si tu veux un truc auto, remplir la variable avec une commande shell 
# doit marcher, cf l'exemple de IGNORE pour l'explication sur le :=
#
# Le nom de l'exe est à renseigner dans EXE_NAME
#
# En gros, au taf, j'ai ça comme arborescence:
# gros projet/
# ├── bite
# │   └── makefile
# ├── common.mk
# ├── couille
# │   └── makefile
# ├── makefile
# ├── nichon
# │   └── makefile
# ├── prout
# │   └── makefile
# └── zob
#     └── makefile
#
# Chaque exe à son makefile, qui est très simple:
# J'y renseigne le nom de l'exe, des flags additionnels, et la liste des .c
# Et ensuite j'inclus le makefile générique (common.mk), qui est environ le 
# contenu du fichier que t'es en train de lire
# Pour les CFLAGS par exemple, j'ai des trucs particuliers dans le makefile
# de l'executable, et je fait un += dans common.mk pour y coller les trucs communs...
# 
# Et enfin le makefile à la racine appelle les sous makefiles, et pond un
# tgz avec le nom de version qui va bien, et tous les exe dedans \o/

# Quelques repetoires utiles...
DIR_SRC = src
DIR_INC = inc
DIR_BIN = bin

# Les trucs de base habituels
CC = gcc
CFLAGS = -W -Wall -Wextra -O3
INC = -I$(DIR_INC)

# L'exe à produire
EXE_NAME = prout
EXE = $(DIR_BIN)/$(EXE_NAME)

# Liste des sources
EXE_SRC = prout.c \
		  prout_aussi.c

# Liste des objets et des dependances à partir de la liste des sources
EXE_OBJ = $(EXE_SRC:%.c=$(DIR_BIN)/%.o)
EXE_DEP = $(EXE_OBJ:%.o=%.d)

# Nom du fichier de version généré par le makefile
EXE_VERSION = $(DIR_INC)/version.h

# Numero de version calculé par git en fonction des tag.
# Au taf lancer un exe avec --version affiche la chaine produite
EXE_RELEASE := `git describe --tags --dirty`

# Petit hack
# La variable ne sert à rien, elle n'est utilisée nulle part.
# Son seul interêt est que l'affectation via := provoque l'appel
# de la commande shell à l'affectation.
# Lors d'une affectation avec un simple =, la valeur de la variable est calculée
# à l'utilisation.
#
# La commande met à jour un numero de version issu de git dans un .h
# Le .h n'est modifié que si nécéssaire, et donc ne provoque pas 
# la recompilation systèmatique du projet: çaybeau
IGNORE := $(shell echo -e "/* Ajoute le tag et la revision git */\nconst char *g_version=\"${EXE_RELEASE}\";\n" > $(EXE_VERSION).tmp && \
                  diff $(EXE_VERSION) $(EXE_VERSION).tmp &> /dev/null || cp $(EXE_VERSION).tmp $(EXE_VERSION) &> /dev/null && \
                  rm $(EXE_VERSION).tmp)

all: $(EXE)

# Compilation des sources
# Subtilité du pipe avant la dépendance avec le repertoire:
# La condition de construction de la regle n'est pas la date
# du repertoire, mais son existence. Remodifier un fichier ne
# fait donc pas refaire le mkdir (la claaaasssse!).
# Gaffe, ça affecte tout ce qui suit apparement...
# La compilation produit au passage un fichier .d qui est un makefile
# listant les dépendances avec les fichiers inclus
$(DIR_BIN)/%.o: $(DIR_SRC)/%.c | $(DIR_BIN)
	$(CC) $(CFLAGS) $(INC) -c -MMD -o $@ $<

# Edition de lien pour produire l'executable
$(EXE): $(LIB) $(EXE_OBJ)
	$(CC) $(LFLAGS) -o $@ $(EXE_OBJ)
	@echo -e "Compilation de `basename $@` \033[1;32mOK\033[0m"

clean:
	@rm -rf $(DIR_BIN)
	@echo -e "Nettoyage de `basename $(EXE)` \033[1;32mOK\033[0m"

$(VERSION): | $(DIR_INC)
	@echo -e "//Ajoute le tag et la revision git\nconst char *sirius_version=\"${RELEASE}\";\n" > $@.tmp
	@diff $@ $@.tmp > /dev/null || cp $@.tmp $@
	@rm $@.tmp

# Inclusion des makefiles qui contiennent les dépendances
# avec les fichiers inclus
# Le moins évite à make de gueuler si le fichier n'existe pas,
# ce qui est le cas après un clean.
-include $(EXE_DEP)

# Creation des repetoires
# Utile avec git qui ne gere pas les repetoires vides par exemple
$(DIR_BIN):
	@mkdir $@

.PHONY: clean all
