; *** Inno Setup version 4 French messages ***
;
; To download user-contributed translations of this file, go to:
;   http://www.jrsoftware.org/is3rdparty.htm
;
; Note: When translating this text, do not add periods (.) to the end of
; messages that didn't have them already, because on those messages Inno
; Setup adds the periods automatically (appending a period would result in
; two periods being displayed).
;
; Transtated by Alain MILANDRE (v3.0.5) email almi@almiservices.com
; Update to v3.0.6 by Alexandre STANCIC email a.stancic@laposte.net
; Update to v4.0.0-pre1 by Romain TARTIERE email romain-tartiere@astase.com

[LangOptions]
LanguageName=French
LanguageID=$0040
; If the language you are translating to requires special font faces or
; sizes, uncomment any of the following entries and change them accordingly.
;DialogFontName=MS Shell Dlg
;DialogFontSize=8
;DialogFontStandardHeight=13
;TitleFontName=Arial
;TitleFontSize=29
;WelcomeFontName=Verdana
;WelcomeFontSize=12
;CopyrightFontName=Arial
;CopyrightFontSize=8

[Messages]

; *** Application titles
SetupAppTitle=Installation
SetupWindowTitle=Installation - %1
UninstallAppTitle=Désinstallation
UninstallAppFullTitle=Désinstallation de %1

; *** Misc. common
InformationTitle=Information
ConfirmTitle=Confirmation
ErrorTitle=Erreur

; *** SetupLdr messages
SetupLdrStartupMessage=%1 va être installé(e). Souhaitez-vous continuer ?
LdrCannotCreateTemp=Impossible de créer un fichier temporaire. Installation annulée
LdrCannotExecTemp=Impossible d'exécuter un fichier depuis le répertoire temporaire. Installation annulée

; *** Startup error messages
LastErrorMessage=%1.%n%nErreur %2: %3
SetupFileMissing=Le fichier %1 n'a pas été trouvé dans le répertoire de l'installation. Corrigez le problème ou obtenez une nouvelle copie du programme.
SetupFileCorrupt=Les fichiers de l'installation sont altérés. Obtenez une nouvelle copie du programme.
SetupFileCorruptOrWrongVer=Les fichiers d'installation sont corrompus ou sont incompatibles avec cette version de l'installeur. Corrigez le problème ou obtenez une nouvelle copie du programme.
NotOnThisPlatform=Ce programme ne s'exécutera pas sur %1.
OnlyOnThisPlatform=Ce programme doit être exécuté sur  %1.
WinVersionTooLowError=Ce programme requiert  %1 version %2 ou supérieure.
WinVersionTooHighError=Ce programme ne peut être installé sur %1 version %2 ou supérieure.
AdminPrivilegesRequired=Vous devez être connecté en tant qu'administrateur pour installer ce programme.
PowerUserPrivilegesRequired=Vous devez être authentifié en tant qu'administrateur ou comme un membre du groupe Administrateurs pour installer ce programme.
SetupAppRunningError=L'installation a détecté que %1 est actuellement en cours d'exécution.%n%nFermez toutes les instances de cette application  maintenant, puis cliquez OK pour continuer, ou Annulation pour arrêter l'installation.
UninstallAppRunningError=La procédure de désinstallation a détecté que %1 est actuellement en cours d'exécution.%n%nFermez toutes les instances de cette application  maintenant, puis cliquez OK pour continuer, ou Annulation pour arrêter l'installation.

; *** Misc. errors
ErrorCreatingDir=L'installeur n'a pas pu créer le répertoire "%1"
ErrorTooManyFilesInDir=L'installeur n'a pas pus créer un fichier dans le répertoire "%1", il doit contenir trop de fichiers

; *** Setup common messages
ExitSetupTitle=Quitter l'installation
ExitSetupMessage=L'installation n'est pas terminée. Si vous quittez maintenant, le programme ne sera pas installé.%n%nVous devrez relancer l'installation une autre fois pour la terminer.%n%nQuitter l'installation ?
AboutSetupMenuItem=&A propos...
AboutSetupTitle=A Propos...
AboutSetupMessage=%1 version %2%n%3%n%n%1 Web:%n%4
AboutSetupNote=

; *** Buttons
ButtonBack=< &Précédent
ButtonNext=&Suivant >
ButtonInstall=&Installer
ButtonOK=OK
ButtonCancel=Annuler
ButtonYes=&Oui
ButtonYesToAll=Oui pour &tout
ButtonNo=&Non
ButtonNoToAll=N&on pour tout
ButtonFinish=&Terminer
ButtonBrowse=&Parcourir...

; *** "Select Language" dialog messages
SelectLanguageTitle=Langue de l'installation
SelectLanguageLabel=Choisissez la langue à utiliser durant la procédure d'installation :

; *** Common wizard text
ClickNext=Cliquez sur "Suivant" pour continuer ou sur "Annuler" pour quitter l'installation.
BeveledLabel=

; *** "Welcome" wizard page
WelcomeLabel1=Bienvenue dans la procédure d'installation de [name]
WelcomeLabel2=Ceci installera [name/ver] sur votre ordinateur.%n%nIl est recommandé de fermer toutes les applications actives avant de continuer.

; *** "Password" wizard page
WizardPassword=Mot de passe
PasswordLabel1=Cette installation est protégée par un mot de passe.
PasswordLabel3=Entrez votre mot de passe.%n%nLes mots de passes tiennent compte des majuscules et des minuscules.
PasswordEditLabel=&Mot de passe :
IncorrectPassword=Le mot de passe entré n'est pas correct. Essayez à nouveau.

; *** "License Agreement" wizard page
WizardLicense=Accord de licence
LicenseLabel=Veuillez lire l'information importante suivante avant de continuer.
LicenseLabel3=Veuillez lire l'accord de licence qui suit. Utilisez la barre de défilement ou la touches "Page suivante" pour lire le reste de la licence.
LicenseAccepted=J'&accepte les termes du contrat de licence
LicenseNotAccepted=Je &refuse les termes du contrat de licence

; *** "Information" wizard pages
WizardInfoBefore=Information
InfoBeforeLabel=Veuillez lire ces informations importantes avant de continuer.
InfoBeforeClickLabel=Lorsque vous serez prêt à continuer, cliquez sur "Suivant".
WizardInfoAfter=Information
InfoAfterLabel=Veuillez lire ces informations importantes avant de continuer.
InfoAfterClickLabel=Lorsque vous serez prêt à continuer, cliquez sur "Suivant".

; *** "User Information" wizard page
WizardUserInfo=Information utilisateur
UserInfoDesc=Veuillez entrer vos coordonnées
UserInfoName=&Nom d'utilisateur:
UserInfoOrg=&Organisation:
UserInfoSerial=Numero de &Série:
UserInfoNameRequired=Vous devez écrire un nom.

; *** "Select Destination Directory" wizard page
WizardSelectDir=Choisissez le répertoire de destination
SelectDirDesc=Où devrait être installé [name] ?
SelectDirLabel=Choisissez le dossier ou vous désirez installer [name], cliquez ensuite sur Suivant.
DiskSpaceMBLabel=Le programme requiert au moins [mb] Mo d'espace disque.
ToUNCPathname=L'installateur ne sait pas utiliser les chemins UNC. Si vous souhaitez installer [name] sur un réseau, vous devez "mapper" un disque.
InvalidPath=Vous devez entrer un chemin complet avec un nom de lecteur; par exemple :%nC:\APP
InvalidDrive=Le lecteur que vous avez sélectionné n'existe pas. Choisissez en un autre.
DiskSpaceWarningTitle=Vous n'avez pas assez d'espace disque
DiskSpaceWarning=L'installation nécessite au moins %1 Ko d'espace disque libre. Le lecteur sélectionné n'a que %2 Ko de disponible.%n%nSouhaitez-vous tout de même continuer ?
BadDirName32=Le nom du répertoire ne peut pas contenir les caractères suivant :%n%n%1
DirExistsTitle=Ce répertoire existe
DirExists=Le répertoire :%n%n%1%n%nexiste déjà. Souhaitez-vous l'utiliser quand même ?
DirDoesntExistTitle=Ce répertoire n'existe pas
DirDoesntExist=Le répertoire :%n%n%1%n%nn'existe pas. Souhaitez-vous qu'il soit créé ?

; *** "Select Components" wizard page
WizardSelectComponents=Sélection des composants
SelectComponentsDesc=Quels sont les composants que vous désirez installer ?
SelectComponentsLabel2=Sélectionnez les composants que vous désirez installer; désactiver les composants que vous ne désirez pas voir installés. Cliquez sur Suivant pour poursuivre la procédure d'installation.
FullInstallation=Installation complète
; if possible don't translate 'Compact' as 'Minimal' (I mean 'Minimal' in your language)
CompactInstallation=Installation Minimum
CustomInstallation=Installation Personnalisée
NoUninstallWarningTitle=Existance d'un composant
NoUninstallWarning=L'Installation à détecté que un ou plusieurs composants sont déjà installés sur votre système:%n%n%1%n%nDésélectionnez ces composants afin de ne pas risquer de les désinstaller.%n%nVoulez-vous tout de même continuer?
ComponentSize1=%1 KB
ComponentSize2=%1 MB
ComponentsDiskSpaceMBLabel=La sélection courante nécessite [mb] MB d'espace disque disponible.

; *** "Select Additional Tasks" wizard page
WizardSelectTasks=Sélection des tâches supplémentaires
SelectTasksDesc=Quels sont les tâches additionnelles que vous désirez exécuter ?
SelectTasksLabel2=Sélectionnez les tâches additionnelles que l'assistant d'installation doit exécuter pendant l'installation de [name], cliquez sur Suivant.

; *** "Select Start Menu Folder" wizard page
WizardSelectProgramGroup=Selectionnez un groupe de programmes
SelectStartMenuFolderDesc=Où voulez vous placer les racourcis du programme ?
SelectStartMenuFolderLabel=Sélectionnez le groupe de programme dans lequel vous désirez que l'assistant d'installation crée les raccourcis du programme, cliquez ensuite sur Suivant.
NoIconsCheck=&Ne pas créer d'icône
MustEnterGroupName=Vous devez entrer un nom de groupe.
BadGroupName=L'installation va ajouter les icones du programme dans le groupe du %1 suivant.
NoProgramGroupCheck2=Ne pas créer le &groupe de programme

; *** "Ready to Install" wizard page
WizardReady=Prêt à installer
ReadyLabel1=L'installateur vas maintenant installer [name] sur votre ordinateur.
ReadyLabel2a=Cliquez sur "Installer" pour continuer ou sur "Précédent" pour changer une option.
ReadyLabel2b=Cliquez sur "Installer" pour continuer.
ReadyMemoUserInfo=Information utilisateur:
ReadyMemoDir=Dossier de destination:
ReadyMemoType=Type d'installation:
ReadyMemoComponents=Composants sélectionnés:
ReadyMemoGroup=Dossier du menu de démarrage:
ReadyMemoTasks=Tâches additionnelles:

; *** "Preparing to Install" wizard page
WizardPreparing=Préparation de la phase d'installation
PreparingDesc=L'assistant d'installation est prêt à installer [name] sur votre ordinateur.
PreviousInstallNotCompleted=L'assistant d'Installation/Désinstallation d'une version précédente du programme n'est pas totalement achevé. Vueillez redémarrer votre ordinateur pour achever la phase d'installation.%n%nAprès le redémarrage de votre ordinateur,  exécutez cet assistant pour exécuter une installation complète de [name].
CannotContinue=L'assistant d'installation ne peut continuer. Veulliez cliquer sur Annuler pour quitter l'Assistant d'installation.

; *** "Installing" wizard page
WizardInstalling=Installation en cours
InstallingLabel=Veuillez patienter pendant que l'assistant d'installation copie [name] sur votre ordinateur.

; *** "Setup Completed" wizard page
FinishedHeadingLabel=Finalisation de l'assistant d'installation de [name]
FinishedLabelNoIcons=L'installation a terminé d'installer [name] sur votre ordinateur.
FinishedLabel=L'installation a terminé d'installer [name] sur votre ordinateur. L'application peut être lancée par la sélection de l'icône installée.
ClickFinish=Cliquez sur Terminer pour quitter la procédure d'installation.
FinishedRestartLabel=Pour finir l'installation de [name], L'installeur doit redémarrer votre ordinateur.%n%nVoulez-vous redémarrer maintenant ?
FinishedRestartMessage=Pour finir l'installation de [name], L'installeur doit redémarrer votre ordinateur.%n%nVoulez-vous redémarrer maintenant ?
ShowReadmeCheck=Oui, Je veux bien lire le fichier LisezMoi
YesRadio=&Oui, Redémarrer l'ordinateur maintenant
NoRadio=&Non, je désire redémarrer mon ordinateur plus tard
; used for example as 'Run MyProg.exe'
RunEntryExec=Executer %1
; used for example as 'View Readme.txt'
RunEntryShellExec=Voir %1

; *** "Setup Needs the Next Disk" stuff
ChangeDiskTitle=L'installation a besoin du disque suivant
SelectDirectory=Sélectionnez un répertoire
SelectDiskLabel2=Veuillez insérer le disque %1 et cliquer sur OK.%n%nSi les fichiers de ce disque peuvent être trouvés dans un %2 différent de celui affiché ci-dessous, entrez le chemin correct ou cliquez sur "Chercher".
PathLabel=&Chemin:
FileNotInDir2=Le fichier "%1" ne peut pas être trouvé dans "%2". Veuillez insérer le disque correct ou sélectionnez un autre %3.
SelectDirectoryLabel=Veuillez indiquer l'emplacement du disque suivant.

; *** Installation phase messages
SetupAborted=L'installation n'a pas été terminée.%n%nVeuillez corriger le problème et relancer l'installation.
EntryAbortRetryIgnore=Cliquez sur "Reprendre" pour essayer à nouveau, sur "Ignorer" pour continuer dans tous les cas, ou sur "Abandonner" pour annuler l'installation.

; *** Installation status messages
StatusCreateDirs=Création des répertoires...
StatusExtractFiles=Extraction des fichiers...
StatusCreateIcons=Création des icônes...
StatusCreateIniEntries=Création des entrées de profils...
StatusCreateRegistryEntries=Création des entrées de registre...
StatusRegisterFiles=Enregistrement des fichiers...
StatusSavingUninstall=Sauvegarde des informations de désinstallation...
StatusRunProgram=Finalisation de l'installation...
StatusRollback=Annulation des changements...

; *** Misc. errors
ErrorInternal2=Erreur interne %1
ErrorFunctionFailedNoCode=%1 échec
ErrorFunctionFailed=%1 échec; code %2
ErrorFunctionFailedWithMessage=%1 échec; code %2.%n%3
ErrorExecutingProgram=Impossible d'exécuter le fichier :%n%1

; *** Registry errors
ErrorRegOpenKey=Erreur pendant l'ouverture de la clef de registre:%n%1\%2
ErrorRegCreateKey=Erreur pendant la création de la clef de registre:%n%1\%2
ErrorRegWriteKey=Erreur lors de l'écriture de la clef de registre:%n%1\%2

; *** INI errors
ErrorIniEntry=Erreur de créaction de l'entrée"%1" du fichier INI.

; *** File copying errors
FileAbortRetryIgnore=Cliquez sur "Reprendre" pour essayer à nouveau, sur "Ignorer" pour ignorer ce fichier (non recommandé), ou sur "Abandonner" pour annuler l'installation.
FileAbortRetryIgnore2=Cliquez sur "Reprendre" pour essayer à nouveau, sur "Ignorer" continuer dans tous les cas (non recommandé), ou sur "Abandonner" pour annuler l'installation.
SourceIsCorrupted=Le fichier source est altéré
SourceDoesntExist=Le fichier source "%1" n'existe pas
ExistingFileReadOnly=Le fichier existe déjà et est en lecture seule.%n%nCliquez sur "Reprendre" pour supprimer l'attribut lecture seule et réessayer, sur "Ignorer" pour ignorer ce fichier, ou sur "Abandonner" pour annuler l'installation.
ErrorReadingExistingDest=Le fichier existe déjà et est en lecture seule.%n%nCliquez sur "Reprendre" pour supprimer l'attribut lecture seule et réessayer, sur "Ignorer" pour ignorer ce fichier, ou sur "Abandonner" pour annuler l'installation.
FileExists=Le fichier existe déjà.%n%nSouhaitez-vous que l'installeur l'écrase ?
ExistingFileNewer=Le fichier existant est plus récent que celui qui doit être installé. Il est recommandé de conserver le fichier existant.%n%nSouhaitez-vous garder le fichier existant ?
ErrorChangingAttr=Une erreur est survenue en essayant de changer les attributs du fichier existant :
ErrorCreatingTemp=Une erreur est survenue en essayant de créer un fichier dans le répertoire de destination :
ErrorReadingSource=Une erreur est survenue lors de la lecture du fichier source :
ErrorCopying=Une erreur est survenue lors de la copie d'un fichier :
ErrorReplacingExistingFile=Une erreur est survenue lors du remplacement d'un fichier existant :
ErrorRestartReplace=Remplacement au redémarrage échoué :
ErrorRenamingTemp=Une erreur est survenue en essayant de renommer un fichier dans le répertoire de destination :
ErrorRegisterServer=Impossible d'enregistrer la librairie : %1
ErrorRegisterServerMissingExport=DllRegisterServer: export non trouvé
ErrorRegisterTypeLib=Impossible d'enregistrer la librairie de type : %1

; *** Post-installation errors
ErrorOpeningReadme=Une erreur est survenue à l'ouverture du fichier LISEZMOI.
ErrorRestartingComputer=L'installeur a été incapable de redémarrer l'ordinateur. Veuillez le faire "manuellement".

; *** Uninstaller messages
UninstallNotFound=Le fichier "%1" n'existe pas. Suppression impossible.
UninstallOpenError=Le fichier "%1" ne peut pas être ouvert. Suppression impossible.
UninstallUnsupportedVer=Le fichier journal de désinstallation "%1" est dans un format non reconnu par cette version du désinstalleur. Impossible de désinstaller ce produit.
UninstallUnknownEntry=Une entrée inconnue (%1) à été rencontrée dans le journal de désinstallation
ConfirmUninstall=Souhaitez-vous supprimer définitivement %1 ainsi que tous ses composants ?
OnlyAdminCanUninstall=Cette application ne peut être supprimée que par un utilisateur possédant les droits d'administration.
UninstallStatusLabel=Patientez pendant la désinstallation de %1 de votre ordinateur.
UninstalledAll=%1 a été supprimé de votre ordinateur.
UninstalledMost=La désinstallation de %1 est terminée.%n%nCertains éléments n'ont pu être supprimés automatiquement. Vous devrez les supprimer "manuellement".
UninstalledAndNeedsRestart=Pour compléter la désinstallation de %1, il faut redémarrer votre ordinateur.%n%nVoulez-vous redémarrer maintenant ?
UninstallDataCorrupted=Le ficher "%1" est altéré. Suppression impossible

; *** Uninstallation phase messages
ConfirmDeleteSharedFileTitle=Supprimer les fichiers partagés ?
ConfirmDeleteSharedFile2=Le système indique que le fichier partagé suivant n'est pas utilisé par d'autres programmes. Souhaitez-vous supprimer celui-ci ?%n%n%1%n%nSi certains programmes utilisent ce fichier et qu'il est supprimé, ces programmes risquent de ne pas fonctionner normallement. Si vous n'êtes pas certain, choisissez Non; laisser ce fichier sur votre système ne pose aucun problème.
SharedFileNameLabel=Nom de fichier:
SharedFileLocationLabel=Emplacement:
WizardUninstalling=Etat de la désinstallation
StatusUninstalling=Désintallation de %1...

