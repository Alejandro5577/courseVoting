// SPDX-License-Identifier: MIT

/**
* Universidad Torcuato Di Tella

* CURSO: Blockchain, Negocios y Web3.0
* PROFESOR: Pablo Roccatagliata
* ALUMNOS:
* - Javier Castiarena 
* - Emiliano Merenda
* - Alejandro Palarich
* 
*
* TÍTULO: Adaptación de "Smart Contract de votación de propuestas" a encuesta de 
* materia universitaria con calificaciones del 1 al 5 
* 
*
* CONSIDERACIONES:
* - Cada proposal es una "pregunta" de la encuesta, ejemplo: puntualidad, material de estudio, puntaje global, etc
* - Cada voto de una proposal tiene una satisfacción del 1-5
* - El contrato se ejecuta una vez por cada materia.
* - En cada ejecución hay n proposals con m votes
*
*
* SECUENCIA DE TIEMPO:
* - Se inicia contrato para la materia X
* - Hay DESDE_HOY_A_INICIO_VOTACION_DIAS días para registrar propuestas (para testing permito en cualquier momento)
* - Se inicia la votación
* - Se pueden registrar votantes en cualquier momento
* - Se van generando votos
* - Finaliza la votación
*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CourseVoting {
    using SafeMath for uint256;

    // VARIABLES
    ERC20 public token;// Token del usuario que va a votar
    uint256 public votingStart;// Datetime inicio votación
    uint256 public votingEnd;// Datetime fin votación
    uint256 public proposalCount; // Cantidad de proposals
    uint256 public votesCount; // Cantidad de votes, es el último voteId en realidad

    uint256 public constant DURACION_VOTACION_DIAS = 5 days;

    /**
    * Permite desfasar el tiempo entre el lanzamiento del contrato y el inicio de la votación
    */
    uint256 public constant DESDE_HOY_A_INICIO_VOTACION_DIAS = 0 days;
    

    /**
     * Data structure for proposals. 
     *
     * Cada Proposal sería una pregunta del tipo. Ej:
     *  Title: Calificación Global Data Science
     *  Descripción: Data Science, profesor: Raccatagliata, UTDT, Electiva 2023
     *  votes: Cantidad de votaciones
     *  totalSatisfaction: Cantidad total de "estrellas"(satisfacción)
     */
    struct Proposal {
        string title;
        string description;
        uint256 votes;
        uint256 totalSatisfaction;
    }

    /**
     * Struct for individual votes
     * Satisfacción del 1 al 5
     */
    struct Voto {
        address voter;
        uint8 satisfaction; 
        uint256 proposalId; 
    }

    /**
     * List of proposals. 
     * Mapea el ID de la propuesta a la estructura de la propuesta
     */
    mapping(uint256 => Proposal) public proposals;

    /**
     * Struct for individual votes
     * Voto debe incluir, address, idProposal, satisfaction
     */
    mapping(uint256 => Voto) public votos;

    /**
     * List of voters
     * Mapea las direcciones de los votantes a un booleano que indica si están registrados como votantes.
     */
    mapping(address => bool) public voters;

    /**
     * Lleva registro de votos realizados por cada Address
     */
    mapping(address => uint256[]) votosPorDireccion;

    /**
     * Constructor
     * -Setea tokeN, fechas de inicio y fin
     */ 
    constructor(address _tokenAddress) {
        token = ERC20(_tokenAddress);
        votingStart = block.timestamp + DESDE_HOY_A_INICIO_VOTACION_DIAS; // la última votación + 10dias? VER
        votingEnd = votingStart + DURACION_VOTACION_DIAS;
    }

    /**
     * Function to create a proposal 
     * - Se pueden crear propuestas mientras la votación está abierta
     * - Se aumenta el contador de proupuestas totales
     * - Se agrega a la estructura de propuestas
     */
    function createProposal(
        string memory _title,
        string memory _description
    ) public {
        // require(block.timestamp >= votingStart, "Encuesta no ha comenzado");// Deshabilito para testing
        require(block.timestamp <= votingEnd, "Encuesta ya finalizo");

        uint256 proposalId = proposalCount + 1;
        proposalCount++;
        proposals[proposalId] = Proposal({
            title: _title,
            description: _description,
            votes: 0,
            totalSatisfaction: 0
        });
    }

    /**
     * Function to register a voter
     *
     * - LO DESHABILITO Validación de tiempo, solo puede registrarse como votantes antes de que inicie la otación
     * - Registra la address como voters
     */
    function registerVoter(address _address) public {
        // require(block.timestamp < votingStart, "Votacion ya comenzo, no se pueden registrar votantes");
        voters[_address] = true;
    }
    

    /**
     * Function to vote for a proposal, con un nivel de satisfacción
     * - Valida que la votación no haya finalizado
     * - Valida que el votante esté registrado
     * - Valida que el votante no haya votado ya
     * - Valida nivel de satisfacción de 1 a 5
     */
    function voteProposal(uint256 _proposalId, uint8 _satisfaction) public {
        require(block.timestamp <= votingEnd, "Encuesta ya finalizo");
        require(voters[msg.sender], "No estas registrado como votante");
        require(_satisfaction >= 1 && _satisfaction <= 5, "La satisfaccion debe estar entre 1 y 5");
        require(!votoExistente(msg.sender, _proposalId), "Ya has votado para esta propuesta");
        

        // Actulizo proposals
        proposals[_proposalId].votes = proposals[_proposalId].votes + 1;
        proposals[_proposalId].totalSatisfaction = proposals[_proposalId].totalSatisfaction + _satisfaction;

        uint256 voteId = votesCount + 1;
        votesCount++;

        // Añadir el ID del voto a la lista de votos por dirección
        votosPorDireccion[msg.sender].push(voteId);

        // Almacenar el voto
        votos[voteId] = Voto({
            voter: msg.sender, 
            satisfaction: _satisfaction, 
            proposalId: _proposalId
        });

    }

    // Función para verificar si un votante ha votado previamente para una proposalID
    function votoExistente(address _voter, uint256 _proposalId) internal view returns (bool) {
        uint256[] memory votosIds = votosPorDireccion[_voter];
        for (uint256 i = 0; i < votosIds.length; i++) {
            uint256 voteId = votosIds[i];
            Voto storage v = votos[voteId];
            if (v.proposalId == _proposalId) {
                return true;
            }
        }
        return false;
    }


    function getVote(address _voter, uint256 _proposalId) public view returns (uint8, uint256) {
        // Iterar a través de los IDs de votos asociados a la dirección
        uint256[] memory votosIds = votosPorDireccion[_voter];
        for (uint256 i = 0; i < votosIds.length; i++) {
            uint256 voteId = votosIds[i];
            Voto storage v = votos[voteId];
            if (v.proposalId == _proposalId) {
                return (v.satisfaction, voteId);
            }
        }

        // Si no se encuentra el voto
        revert("Voto no encontrado");
    }


    /**
     * Function to get the voting result. Promedio de satisfacción para la propuesta
     * - Valida división por cero
     */
    function getAvgSatisfaction(
        uint256 _proposalId
    ) public view returns (uint256 integerPart, uint256 decimalPart) {
        require(proposals[_proposalId].votes > 0, "No hay votos aun");

        // Hacer la división manteniendo suficientes dígitos para los decimales
        uint256 rawAvg = (proposals[_proposalId].totalSatisfaction * 10**18) / proposals[_proposalId].votes;
        // Separar la parte entera y decimal
        integerPart = rawAvg / 10**18;
        decimalPart = rawAvg % 10**18;
    }
}
