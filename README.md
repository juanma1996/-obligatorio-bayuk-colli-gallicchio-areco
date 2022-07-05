[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-c66648af7eb3fe8bc4f294546bfd86ef473780cde1dea487d3c4ff354943c9ae.svg)](https://classroom.github.com/online_ide?assignment_repo_id=7872879&assignment_repo_type=AssignmentRepo)

### Descripción del proyecto
Mediante la aplicación de tecnicas de programación de contratos inteligentes e interconexion por medio de una DApp, se diseñó una plataforma que brinda funciones de valor para usuarios.

Se creeó un token siguendo el estándar ERC-20 y un contrato que permite la compra y venta de dicho token entre los dueños de la plataforma y los usuarios siguiendo una serie de reglas de negocio. Los usuarios pueden a su vez, realizar staking del token para obtener más tokens.

Se adjunta un diagrama en el cual se puede ver los contratos, sus metodos y a su vez las comunicaciones entre ellos. 

### Componentes del proyecto
El proyecto se divide en tres contratos:

1. Contrato TokenContract: contrato en donde se encuentra la logica del token, desde el se pueden mintear tokens bajo la orden del contrato Vault, y tambien se pueden quemar tokens de cuentas que no provengan de Vault. 

2. Contrato Vault: contrato multifirma que funciona como una bóveda para resguardar los tokens minteados, a traves de este contrato los usuarios pueden comprar y vender sus tokens a cambio de ethers.

2. Contrato Farm: es el contrato de staking en donde los usuarios obtienen más tokens (en funcion de APR) al realizar staking sobre los suyos. 

### Pasos para hacer el Setup del repositorio
- Se debe clonar el repositorio.
- Instalar todas las dependencias mediante el comando npm install.

### Pasos para hacer el Deploy del proyecto

Se debe tener instalado Hardhat, y se deben configurar las variables del ambiente.

Comando para deployar:
npx hardhat run scripts/deploy.js

### Pasos para hacer la ejecución de test del proyecto

- Ejecutar el comando 'npx hardhat node' y verificar que inicializa la red local de hardhat.
- Para correr los tests ejecutar el comando 'npx hardhat test'.

### Address de contratos deployados en testnet

###  Integrantes del equipo

| Nombre      | Num. de Estudiante      |  Address |
| ------------      | -----:  | :----:  |
| Agustin Bayuk      | 213116    |    0x860c9A39CA66d66353E6E233b4D04c47C2A4388F    |
| Carlos Colli| 136382     |    0x397C2cc359f9318E802aF7cd5545117175190d80     |
| Paula Areco| 234219     |    0x42684d4665079969937C7064b31Ea6A9172cF2e3      |
| Juan Manuel Gallicchio| 233335      |    0x8fB32163b178984e8f1b204f5527DE8A9D1bEBB8       |

                    

### Metodología de Trabajo
Se trabajó con el flujo de trabajo GitFlow. Las ventajas de trabajar con el mismo es tener un mayor control del flujo de trabajo, proporcionar una mayor agilidad en el momento de implementar nuevas funcionalidades, disminuir los errores que se producen a causa de mezcla de ramas, así como también para mantener una versión estable en la rama principal.

Se utilizó main como rama base, develop como rama de desarrollo y a ella convergen las ramas de features implementados, se pueden encontrar a su vez algunas ramas fix.  Se realizaron también algunos pull request para aplicar la revisión entre pares (aunque generalmente la revision terminó en refactoring del código por parte de algún otro integrante del equipo) y finalmente se hizo el merge de las ramas a develop. La versión final del proyecto se encuentra en la rama main.

Se adjunta a continuación una visualizacion gráfica de las ramas, capturada en la herramienta https://fork.dev/. 

<img width="1014" alt="gitflow" src="https://user-images.githubusercontent.com/61010536/177241418-2b0a79b7-7967-4b92-9a2c-f6ee4737bffc.png">

El proyecto comenzó con reuniones semanales para definir la estructura general del proyecto y delegar las tareas. Para el almacenamiento de las tareas, seguimiento y el control de avance se usó Trello con tres columnas: 
1. TO DO que representa el backlog del proyecto, las tareas a realizar.
2. DOING para las tareas en progreso.
3. DONE para significar que la tarea se termino.

Las tarjetas a su vez se dividieron en tareas que representan cada una los métodos requeridos en la letra, finalizar todas las tareas da un porcentaje de 100% en la tarjeta y se significa que la misma puede pasar a la columna DONE. Visualizacion del tablero cuando el proyecto estaba casi en su finalidad:

<img width="1091" alt="trello-cards" src="https://user-images.githubusercontent.com/61010536/177241090-6c99d2bf-24a9-4db1-a21d-baf6b372e61a.png"> 

Cada tarjeta y sus tareas: 

![trello-card](https://user-images.githubusercontent.com/61010536/177241950-8e855bd9-e805-48b7-830b-bb60d10b4502.jpg)


Al avanzar el proyecto se realizaron daily meetings, y se usaron las muestras de avance en clase como reuniones retrospectivas para recibir feedback.

### Diagrama
Mediante el diagrama logramos modelar la realidad propuesta, mostrando los contratos, atributos, constructores, metodos, estructuras auxiliares y las llamadas entre contratos. 

El diagrama se puede ver aqui: https://drive.google.com/file/d/1zMrSiytfmbrRtowe8o4J8IO2YW9Z-vAE/view?usp=sharing 

### Decisiones de Diseño
- Para resolver el requisito de validacion de administradores en Vault se utilizó el patrón Ownable, a su vez se usó en Farm y TokenContract para asegurarse que solamente el owner del contrato sea quien aplique la función set de las address de los demás contratos para hacer posible la comunicación entre ellos. Lo que se busca con la implementación del mismo es evitar operaciones maliciosas y restringir a que solo determinadas address puedan realizar determinadas funciones.