// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/CourseVoting.sol";
import "./TimeManipulator.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract CourseVotingTest {

    CourseVoting courseVoting;
    TimeManipulator timeManipulator;

    address voterAddress;
    uint256 public constant DESDE_HOY_A_INICIO_VOTACION_DIAS = 0 days; // sería como un tiempo hasta el inicio, por ejempl si en el medio hay un examen.


    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // <instantiate contract>
        courseVoting = new CourseVoting(address(this)); // Deploy a new instance of CourseVoting for testing
        voterAddress = TestsAccounts.getAccount(1);
        Assert.equal(uint(1), uint(1), "1 should be equal to 1");
    }

    function testCreateProposal() public {
       
        // uint256 tiempoParaEsperar = DESDE_HOY_A_INICIO_VOTACION_DIAS;
        // timeManipulator.increaseTime(tiempoParaEsperar);
   
        courseVoting.registerVoter(voterAddress);

        courseVoting.createProposal("Proposal Title", "Proposal Description");
        uint256 proposalCount = courseVoting.proposalCount();
        Assert.equal(proposalCount, 1, "Proposal creation failed");
    }

    function testRegisterVoter() public {
        courseVoting.registerVoter(voterAddress);
        Assert.equal(courseVoting.voters(voterAddress), true, "Voter registration failed");
    }

    

    function testVoteProposal() public {
        courseVoting.registerVoter(voterAddress);
        courseVoting.createProposal("Disponibilidad de material de estudio", "Variedad y facilidad de acceso");

        uint256 proposalId = 1;
        uint8 satisfaction = 4; // Asumiendo que la satisfacción es 4 en una escala de 1 a 5
        courseVoting.voteProposal(proposalId, satisfaction);

        (, , uint256 votes,) = courseVoting.proposals(proposalId);

        Assert.equal(votes, 1, "Encuesta fallo");
    }


    function testGetAvgSatisfaction() public {
        courseVoting.registerVoter(voterAddress);
        courseVoting.createProposal("Puntualidad", "Inicio, fin de clases y breaks");

        uint256 proposalId = 1;
        uint8 satisfaction = 4;
        courseVoting.voteProposal(proposalId, satisfaction);

        uint256 avgSatisfaction = courseVoting.getAvgSatisfaction(proposalId);
        Assert.equal(avgSatisfaction, satisfaction, "Fallo el calculo del promedio de estrellas");
    }
}
    