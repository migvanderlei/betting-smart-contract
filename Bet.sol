// Autor: Miguel Vanderlei de Oliveira (mvo.snf18@uea.edu.br)
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Aposta {
        
    address public owner;

    uint256 public valorApostadoTotal;
    uint256 public qtdApostasTotal;
    string[] public times;

    struct Time {
        string nome;
        uint256 valorApostado;
        uint256 qtdApostas;
        bool existe;
        address[] apostadores;
    }

    struct Apostador {
        uint256 valorApostado;
        string time;
    }

    mapping(address => Apostador) enderecosApostadores;

    mapping(string => Time) apostasTimes;


    modifier isOwner() {
        require(msg.sender == owner, "Somente o owner pode chamar esse metodo!");
        _;
    }
    

    constructor (string[] memory listaTimes) {
        owner = msg.sender;
        times = new string[](0);

        for (uint i=0; i< listaTimes.length; i++) {

            string memory nomeTime = string(listaTimes[i]);

            times.push(nomeTime);

            Time memory novoTime = Time({
                nome: nomeTime,
                valorApostado: 0,
                qtdApostas: 0,
                existe: true,
                apostadores: new address[](0)
            });
            
            apostasTimes[nomeTime] = novoTime;
        }
    }

   function apostar(string calldata time) public payable {

        require(apostasTimes[time].existe, "Voce deve apostar em um time cadastrado!");

        uint256 valor = msg.value;
        address apostador = msg.sender;

        Apostador memory novoApostador = Apostador({
            valorApostado : valor,
            time: time
        });
        
        enderecosApostadores[apostador] = novoApostador;

        valorApostadoTotal += valor;
        qtdApostasTotal++;

        Time storage timeApostado = apostasTimes[time];

        timeApostado.valorApostado += valor;
        timeApostado.qtdApostas++;
        timeApostado.apostadores.push(apostador);
        
        apostasTimes[time] = timeApostado;
    }

    function encerrarAposta(string memory nomeTimeVencedor) public isOwner {
        require(apostasTimes[nomeTimeVencedor].existe, "Somente times cadastrados podem vencer!");

        Time memory timeVencedor = apostasTimes[nomeTimeVencedor];

        address[] memory apostadoresVencedores = timeVencedor.apostadores;
        uint256 totalApostasTimeVencedor = timeVencedor.valorApostado;
        uint256 totalApostasTimesPerdedores = valorApostadoTotal - timeVencedor.valorApostado;


         for (uint i=0; i< apostadoresVencedores.length; i++) {

            Apostador memory apostador = enderecosApostadores[apostadoresVencedores[i]];
            uint256 valorApostado = apostador.valorApostado;
            
            uint256 valorPagamento = valorApostado + (valorApostado/totalApostasTimeVencedor) * totalApostasTimesPerdedores;

            payable(apostadoresVencedores[i]).transfer(valorPagamento);

         }        


    }
}
