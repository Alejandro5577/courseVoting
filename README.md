# courseVoting
Smart Contract en Solidity para votación de propuestas con calificación de 1 a 5

## Adaptación de "Smart Contract de votación de propuestas" a encuesta de materia universitaria con calificaciones del 1 al 5 

## Materia: Blockchain, Negocios y Web3.0
## Modalidad EMBA22 - Universidad Torcuato Di Tella

## Profesor: 
- Pablo Roccatagliata

## Alumnos:
- Javier Castiarena 
- Emiliano Merenda
- Alejandro Palarich


### CONSIDERACIONES:
- Cada proposal es una "pregunta" de la encuesta, ejemplo: puntualidad, material de estudio, puntaje global, etc
- Cada voto de una proposal tiene una satisfacción del 1-5
- El contrato se ejecuta una vez por cada materia.
- En cada ejecución hay n proposals con m votes


### SECUENCIA DE TIEMPO:
- Se inicia contrato para la materia X
- Hay DESDE_HOY_A_INICIO_VOTACION_DIAS días para registrar propuestas (para testing permito en cualquier momento)
- Se inicia la votación
- Se pueden registrar votantes en cualquier momento
- Se van generando votos
- Finaliza la votación


# DOCUMENTACIÓN CÓDIGO
## VARIABLES
- *token*: Del usuario que va a votar
- votingStart: Datetime inicio votación
- votingEnd: Datetime fin votación
- proposalCount: Cantidad de proposals
- votesCount: Cantidad de votes, es el último voteId en realidad

## CONSTANTES
- DURACION_VOTACION_DIAS = 5
- DESDE_HOY_A_INICIO_VOTACION_DIAS: Permite desfasar el tiempo entre el lanzamiento del contrato y el inicio de la votación

## STRUCTURES
- Proposal:  {
        string title;
        string description;
        uint256 votes;
        uint256 totalSatisfaction;
    }

- Voto {
        address voter;
        uint8 satisfaction; 
        uint256 proposalId; 
    }


## MÉTODOS

- constructor(address _tokenAddress): Cuando se lanza el contracto asigna la variable token y los tiempos de votingStart y votingEnd

- registerVoter(address _address): Registra a la address como votante

- createProposal( string memory _title, string memory _description ): Registra una propuesta en la estructura correspondiente, con un título y una descripción. Por ejemplo: Calidad de la bibliografía, puntualidad del profesor, puntaje global de la materia.

- voteProposal(uint256 _proposalId, uint8 _satisfaction): Crear una votación con un nivel de satisfacción para una proposalId. Previamente realiza las validaciones correspondientes, de tiempo, que la calificación sea de 1 a 5 y qu el votante no haya votado previamente esta propueta.

- votoExistente(address _voter, uint256 _proposalId): Verifica si un votante ya votó una proposalId

- getVote(address _voter, uint256 _proposalId): Información de cierto voto, a partir del votantes y la propuesta

- getAvgSatisfaction(uint256 _proposalId): Devuelve la parte entera y decimal del promedio de calificaciones de una propuesta


