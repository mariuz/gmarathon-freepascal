; *** Inno Setup version 4.0.5+ English messages ***
;
; To download user-contributed translations of this file, go to:
;   http://www.jrsoftware.org/is3rdparty.php
;
; Note: When translating this text, do not add periods (.) to the end of
; messages that didn't have them already, because on those messages Inno
; Setup adds the periods automatically (appending a period would result in
; two periods being displayed).
;
; $jrsoftware: issrc/Files/Default.isl,v 1.32 2003/06/18 19:24:07 jr Exp $

[LangOptions]
LanguageName=Spanish
LanguageID=$0409
; If the language you are translating to requires special font faces or
; sizes, uncomment any of the following entries and change them accordingly.
DialogFontName=MS Shell Dlg
DialogFontSize=8
DialogFontStandardHeight=13
TitleFontName=Arial
TitleFontSize=29
WelcomeFontName=Verdana
WelcomeFontSize=12
CopyrightFontName=Arial
CopyrightFontSize=8

[Messages]

; *** Application titles
SetupAppTitle=Instalar
SetupWindowTitle=Instalador - %1
UninstallAppTitle=DesInstalar
UninstallAppFullTitle=Desinstalar %1

; *** Misc. common
InformationTitle=Información
ConfirmTitle=Confirmar
ErrorTitle=Problemas

; *** SetupLdr messages
SetupLdrStartupMessage=Este programa instalará %1. ¿Desea Continuar?
LdrCannotCreateTemp=Imposible crear un directorio temporal, Instalación abortada
LdrCannotExecTemp=Imposible ejecutar programa desde directorio temporal, instalación abortada

; *** Startup error messages
LastErrorMessage=%1.%n%nError %2: %3
SetupFileMissing=No se encuentra el archivo %1 en el directorio de instalación. Corrija el problema obteniendo una nueva copia del programa.
SetupFileCorrupt=El archivo de instalación esta corrupto, Por favor obtenga una nueva copia de este.
SetupFileCorruptOrWrongVer=Los archivos de instalación estan corruptos, o son incompatibles con esta version del instalador. Corrija el problema obteniendo una nueva copia del programa.
NotOnThisPlatform=Este progrma no se ejecutara en %1.
OnlyOnThisPlatform=Este programa debe correr en %1.
WinVersionTooLowError=Este programa require %1 versión %2 o posterior.
WinVersionTooHighError=Este programa no puede ser instalado en %1 o versión %2 o posterior.
AdminPrivilegesRequired=Usted debe ingresar como administrador para instalar este programa.
PowerUserPrivilegesRequired=Usted debe ingresar como administrador o como miembro de usuarios con privilegios para instalar este programa.
SetupAppRunningError=Instalar ha detectado que %1 esta actualmente ejecutandose.%n%nPor favor cierre todas las instancias de este y luego haga click en continuar o cancelar para salir.
UninstallAppRunningError=Desinstalar ha detectado que %1 esta actualmente ejecutandose.%n%nPor favor cierre todas las instancias de este y luego haga click en continuar o cancelar para salir.

; *** Misc. errors
ErrorCreatingDir=Instalar no ha podido crear el directorio "%1"
ErrorTooManyFilesInDir=Imposible crear archivos en el directorio "%1" porque este contiene muchos archivos.

; *** Setup common messages
ExitSetupTitle=Salir de Instalar
ExitSetupMessage=La instalación no esta completa. Si termina ahora el programa no sera instalado.%n%nDebera ejecutar instalar nuevamente en otra oportunidad para completar la instalacion.%n%n¿Salir de Instalar?
AboutSetupMenuItem=&Acerca de instalar ...
AboutSetupTitle=Acerca de Instalar
AboutSetupMessage=%1 versión %2%n%3%n%n%1 home page:%n%4
AboutSetupNote=

; *** Buttons
ButtonBack=< &Atras
ButtonNext=&Siguiente >
ButtonInstall=&Instalar
ButtonOK=OK
ButtonCancel=Cancelar
ButtonYes=&Si
ButtonYesToAll=Si a &Todo
ButtonNo=&No
ButtonNoToAll=N&o a Todo
ButtonFinish=&Finalizar
ButtonBrowse=&Explorar...

; *** "Select Language" dialog messages
SelectLanguageTitle=Seleccione el idioma del instalador
SelectLanguageLabel=Seleccione el idioma a utilizar durante la instalación:

; *** Common wizard text
ClickNext=Click en siguiente para continua, o cancelar para salir de instalar.
BeveledLabel=

; *** "Welcome" wizard page
WelcomeLabel1=Bienvenido a asistente de instalación de [name] 
WelcomeLabel2=Este programa  instalara [name/ver] en su computadora.%n%nEs recomendable que cierre todas las aplicaciones antes de continuar.%n

; *** "Password" wizard page
WizardPassword=Contraseña
PasswordLabel1=Esta instalación est protegida con contraseña.
PasswordLabel3=Por favor indique la contraseña, y haga click en siguiente. la contraseña es sensible a mayúsculas y minúsculas.
PasswordEditLabel=&Contraseña:
IncorrectPassword=La contraseña que ingreso no es correcta, intente otra vez.

; *** "License Agreement" wizard page
WizardLicense=Consentimiento de licencia
LicenseLabel=Por favor lea la siguiente información antes de continuar.
LicenseLabel3=Por favor lea la siguiente información de licenciamiento antes de continuar. Usted debe aceptar los terminos de esta antes de continuar con la instalación.
LicenseAccepted=Yo &Acepto los términos de licencia.
LicenseNotAccepted=Yo &No acepto los términos de la licencia.

; *** "Information" wizard pages
WizardInfoBefore=Información
InfoBeforeLabel=Por favor lea la siguiente información antes de continuar.
InfoBeforeClickLabel=Cuando este listo para continuar presione siguiente.
WizardInfoAfter=Información
InfoAfterLabel=Por favor lea la siguiente información antes de continuar.
InfoAfterClickLabel=Cuando este listo para continuar presione siguiente.

; *** "User Information" wizard page
WizardUserInfo=Información de usuario
UserInfoDesc=Por favor ingrese su información.
UserInfoName=&Nombre Usuario:
UserInfoOrg=&Organización:
UserInfoSerial=Número de &Serie:
UserInfoNameRequired=Debe ingresar un nombre.

; *** "Select Destination Directory" wizard page
WizardSelectDir=Seleccione el directorio de instalación
SelectDirDesc=¿Donde será instalado [name]?
SelectDirLabel=Seleccione la carpeta donde [name] sera instalado y presione siguiente.
DiskSpaceMBLabel=Este programa requiere a lo menos [mb] mb de espacio en el disco.
ToUNCPathname=Instalar no puede usar directorios con nomenclatura UNC, para instalar en una red usted debe asignar una letra de unidad antes de ejecutar la instalación.
InvalidPath=Usted debe indicar una ruta valida, por ejemplo:%n%nc:\archivos de programa\app%n%no una ruta UNC de la forma:%n%n\\servidor\carpeta
InvalidDrive=El dispositivo o la carpeta de red compartida no existe o no es accesible. Por favor seleccione otra.
DiskSpaceWarningTitle=No posee espacio en disco
DiskSpaceWarning=Instalar requiere a lo menos %1 KB de espacio para instalar, peru usted ha seleccionado un dispositivo solo con %2 KB disponibles.%n%n¿Desea continuar de todas maneras?
BadDirName32=El nombre del directorio no puede incluir alguno de los siguientes caracteres.%n%n%1
DirExistsTitle=Directorio Existente
DirExists=El directorio:%n%n%1%n%nya existe, ¿Desea instalar en el de todas maneras?
DirDoesntExistTitle=El directorio no existe
DirDoesntExist=El directorio :%n%n%1%n%nno existe. ¿Desea crearlo?

; *** "Select Components" wizard page
WizardSelectComponents=Seleccione los componentes
SelectComponentsDesc=¿Que componentes desea instalar?
SelectComponentsLabel2=Seleccione los componetes a instalar; desmarque los componentes que no desea instalar. Haga click en siguiente cuando este listo.
FullInstallation=Instalación Completa
; if possible don't translate 'Compact' as 'Minimal' (I mean 'Minimal' in your language)
CompactInstallation=Instalción Reducida
CustomInstallation=Instalación personalizada
NoUninstallWarningTitle=Los componentes existen
NoUninstallWarning=Instalar ha detectado que los siguientes componentes se encuentran instaladoe en su ordenador:%n%n%1%n%nDeseleccionándolos no serán desinstalados.%n%n¿Desea continuar de todas maneras?
ComponentSize1=%1 KB
ComponentSize2=%1 MB
ComponentsDiskSpaceMBLabel=La selección requiere a lo menos [mb] MB de espacio en disco.

; *** "Select Additional Tasks" wizard page
WizardSelectTasks=Seleccione tareas adicionales
SelectTasksDesc=¿Que tareas adicionales deberan ser realizadas?
SelectTasksLabel2=Seleccione las tareas adicionales que instalar realizara cuando instale [name], y haga click en siguiente.

; *** "Select Start Menu Folder" wizard page
WizardSelectProgramGroup=Seleccione la carpeta del menu inicio
SelectStartMenuFolderDesc=¿Donde instalar debe colocar los accesos directos?
SelectStartMenuFolderLabel=Seleccione la carpeta del menu inicio donde instalar creara los accesos directos de la aplicacion y haga click en siguiente.
NoIconsCheck=&No crear ningun icono
MustEnterGroupName=Debe ingresar un nombre de carpeta
BadGroupName=El nombre de carpeta no puede contener ninguno de los siguientes caracteres:%n%n%1
NoProgramGroupCheck2=&No crear una carpeta en menu inicio

; *** "Ready to Install" wizard page
WizardReady=Listo para instalar
ReadyLabel1=Instalar esta listo para instalar [name] en su computadora.
ReadyLabel2a=Presione instalar para continuar con la instalación, o presione atras para realizar cambios en los parametros de instalación.
ReadyLabel2b=Presione Instalar para continuar con la instalación.
ReadyMemoUserInfo=Información de usuario:
ReadyMemoDir=Directorio destino:
ReadyMemoType=Tipo de instalación:
ReadyMemoComponents=Componentes seleccionados:
ReadyMemoGroup=Carpeta menu inicio:
ReadyMemoTasks=Tareas Adicionales:

; *** "Preparing to Install" wizard page
WizardPreparing=Preparandose para instalar
PreparingDesc=Instalar se esta preparando para instalar [name] en su computadora.
PreviousInstallNotCompleted=La instalación o desinstalación de un programa previo no fue completado. Debe reiniciar su computadora para completar la instalación.%n%nDespues de reiniciar, ejecute instalar nuevamente para completar la instalacion de [name].
CannotContinue=Instalar no puede continuar. Por favor presione cancelar para salir.

; *** "Installing" wizard page
WizardInstalling=Instalando
InstallingLabel=Por favor espere mientras instalar instala [name] en su computadora.

; *** "Setup Completed" wizard page
FinishedHeadingLabel=Completando la instalación de [name]
FinishedLabelNoIcons=Instalar ha finalizado con la instalación de [name] en su computadora.
FinishedLabel=Instalar ha finalizado con la instalación de [name] en su computadora. La aplicación puede ser ejecutada mediante los accesos directos.
ClickFinish=Presione Finalizar para salir de instalar.
FinishedRestartLabel=Para completar la instalación de [name], instalar debe reiniciar su computadora, ¿Desea reiniciarla ahora?
FinishedRestartMessage=Para completar la instalación de [name], instalar debe reiniciar su computadora, %n%n¿Desea reiniciarla ahora?
ShowReadmeCheck=Si, deseo leer el archivo LEAME
YesRadio=&SI, Reinicie mi computadora en este momento
NoRadio=&NO, reiniciare la computadora luego
; used for example as 'Run MyProg.exe'
RunEntryExec=Ejecutar %1
; used for example as 'View Readme.txt'
RunEntryShellExec=Ver %1

; *** "Setup Needs the Next Disk" stuff
ChangeDiskTitle=Instalar necesita el siguiente disco
SelectDirectory=Seleccione un directorio
SelectDiskLabel2=Por favor inserte el disco %1 y presione OK%n%nSi los archivos en el disco no pueden ser encontrados o estan en otra carpeta, ingrese la ruta correcta o presione explorar.
PathLabel=&Ruta:
FileNotInDir2=El archivo "%1" no pudo ser encontrado en "%2". por favor inserte el disco correcto o seleccione otra carpeta.
SelectDirectoryLabel=Por favor especifique la ubicacion de el siguiente disco.

; *** Installation phase messages
SetupAborted=La instalación no esta completa.%n%nPor favor corrija el problema y ejecute instalar nuevamente.
EntryAbortRetryIgnore=Presione Reintentar para tratar nuevamente, ignorar para proceder de todas maneras, o abortar para cancelar la instalación.

; *** Installation status messages
StatusCreateDirs=Creando Directorios...
StatusExtractFiles=Extrayendo archivos...
StatusCreateIcons=Creando iconos de programa...
StatusCreateIniEntries=Creando entradas INI...
StatusCreateRegistryEntries=Creando entradas de registro...
StatusRegisterFiles=Registrando archivos...
StatusSavingUninstall=Guardando información para desinstalar...
StatusRunProgram=Finalizando instalación...
StatusRollback=Dehaciendo cambios...

; *** Misc. errors
ErrorInternal2=Error interno: %1
ErrorFunctionFailedNoCode=%1 fallo
ErrorFunctionFailed=%1 fallo; código %2
ErrorFunctionFailedWithMessage=%1 fallo; código %2.%n%3
ErrorExecutingProgram=No se puede ejecutar el archivo:%n%1

; *** Registry errors
ErrorRegOpenKey=Error al abir la clave del registro:%n%1\%2
ErrorRegCreateKey=Error al crear la clave del registro:%n%1\%2
ErrorRegWriteKey=Error al escribir la clave del registro:%n%1\%2

; *** INI errors
ErrorIniEntry=Error al crear entrada INI en el archivo "%1".

; *** File copying errors
FileAbortRetryIgnore=Presione Reitentar para intentarlo nuevamente, Ignorar para ignorar este archivo (no recomendado), o Abortar para cancelar instalación.
FileAbortRetryIgnore2=Click en reintentar para tratar otra vez, ignorar para proceder de todas maneras (no recomendado), o abortar para cancelar la instalación.
SourceIsCorrupted=El archivo fuente esta corrupto
SourceDoesntExist=El archivo fuente "%1" no existe
ExistingFileReadOnly=El archivo existente esta marcado como solo lectura.%n%nPresione Reintentar para remover la proteccion y tratar nuevamente, ignorar para saltar la copia de este archivo o abortar para cancelar la instalación.
ErrorReadingExistingDest=Un error ha ocurrido mientras trataba de leer el archivo existente:
FileExists=El arcchivo existe.%n%n¿Desea que instalar lo sobre escriba?
ExistingFileNewer=El archivo existente es mas nuevo que el que se esta intentando copiar, es recomendable que mantenga el archivo existente.%n%n¿desea mantener el archivo existente?
ErrorChangingAttr=Ha ocurrido un error mientras se intentaba cambiar los atributos del archivo existente:
ErrorCreatingTemp=Un error ha ocurrido mientras trataba de crear un archivo en el directorio destino:
ErrorReadingSource=Un error ha ocurrido mientras trataba de leer el archivo fuente:
ErrorCopying=Un error ha ocurrido mientras trataba de copiar el archivo:
ErrorReplacingExistingFile=Un error ha ocurrido mientras tratba de reemplazar el archivo existente:
ErrorRestartReplace=Reiniciar/reemplazar fallo:
ErrorRenamingTemp=Un error ha ocurrido mientras trataba de renombrar un archivo en el directorio destino:
ErrorRegisterServer=No se puede registrar la DLL/OCX: %1
ErrorRegisterServerMissingExport=DllRegisterServer export no encontrada
ErrorRegisterTypeLib=No es posible registrar el tipo de biblioteca: %1

; *** Post-installation errors
ErrorOpeningReadme=Un error ha ocurrido mientras trataba de abrir el archivo LEAME.
ErrorRestartingComputer=Instalar no fue capaz de reiniciar su computadora. Por favor realice la operacion manualmente.

; *** Uninstaller messages
UninstallNotFound=El archivo "%1" no existe. no puede continuar desinstalando.
UninstallOpenError=El archivo "%1" no pudo abrirse. No se puede desinstalar
UninstallUnsupportedVer=El registro de desinstalación "%1" esta en un formato no reconocido por esta version de desinstalar, No puede desinstalar
UninstallUnknownEntry=Una entrada desconocida (%1) ha sido encontrada en el registro de desinstalación
ConfirmUninstall=¿Esta seguro de remover completamente %1 y todos sus componentes?
OnlyAdminCanUninstall=La instalación solo puede ser removida por algun usuario con privilegios de administrador.
UninstallStatusLabel=Por favor espere mientras %1 es removido desde su sistema.
UninstalledAll=%1 fue exitosamente removido de su sistema.
UninstalledMost=Desinstalacion de %1 completa%n%nAlgunos elementos no pudieron ser removidos. pueden ser removidos manualmente.
UninstalledAndNeedsRestart=Para completar la desinstalación de %1, su computadora debe ser reiniciada%n%n¿Desea reiniciarla ahora? 
UninstallDataCorrupted=el archivo "%1" esta corrupto. No se puede desinstalar

; *** Uninstallation phase messages
ConfirmDeleteSharedFileTitle=¿Eliminar carpeta compartida?
ConfirmDeleteSharedFile2=El sistema indica que los siguientes archivos no estan siendo utilizados por ningun programa. ¿Desea que desinstalar remueva estos componentes compartidos?%n%nSi esiste cualquier programa que siga utilizando dichos archivos, quedara inutilizable, si no esta seguro elija NO, dejar el archivo en su computadora no causara ningun daño.
SharedFileNameLabel=Nombre del archivo:
SharedFileLocationLabel=Ubicación:
WizardUninstalling=Estado de la desinstalación
StatusUninstalling=Desinstalando %1...
