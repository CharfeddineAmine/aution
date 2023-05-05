// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;




import "@openzeppelin/contracts@4.8.3/token/ERC20/ERC20.sol";




pragma solidity ^0.8.0;

contract SimpleAuction {
    // Adresse du vendeur
    address payable public seller;
    // Temps de fin d'enchère (timestamp)
    uint public auctionEndTime;
    // Prix minimum pour l'enchère
    uint public minValue;
    // Adresse de l'offrant ayant fait la plus haute enchère
    address public highestBidder;
    // Montant de l'offre la plus élevée
    uint public highestBid;
    // Mapping pour stocker les montants en attente de remboursement
    mapping(address => uint) public pendingReturns;
    // Booléen pour indiquer si l'enchère est terminée
    bool ended;

    // Evénement pour notifier qu'une offre a été faite
    event HighestBidIncreased(address bidder, uint amount);
    // Evénement pour notifier la fin de l'enchère
    event AuctionEnded(address winner, uint amount);

    // Constructeur pour initialiser les variables
    constructor(
        uint _biddingTime,
        address payable _seller,
        uint _minValue
    ) {
        seller = _seller;
        auctionEndTime = block.timestamp + _biddingTime;
        minValue = _minValue;
    }

    // Fonction pour faire une offre
    function bid() public payable {
        // Vérifier que l'enchère est en cours
        require(
            block.timestamp <= auctionEndTime,
            "L'enchere est terminee."
        );
        // Vérifier que le montant est supérieur à l'offre précédente et au prix minimum
        require(msg.value > highestBid, "il y a une offre plus elevee");
        require(msg.value >= minValue, "Le montant de l'offre est trop faible.");
        // Si l'offrant a déjà fait une offre, rembourser le montant précédent
        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
        // Mettre à jour le plus haut offrant
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    // Fonction pour récupérer le montant en attente de remboursement
    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    // Fonction pour terminer l'enchère et transférer les fonds au vendeur
    function auctionEnd() public {
        // Vérifier que l'enchère est terminée
        require(
            block.timestamp >= auctionEndTime,
            "L'enchere n'est pas terminee."
        );
        // Vérifier que l'enchère n'a pas déjà été terminée
        require(!ended, "L'enchere est deja terminee.");
        ended = true;
        // Émettre l'événement de fin d'enchère
        emit AuctionEnded(highestBidder, highestBid);
        // Transférer les fonds au vendeur
        seller.transfer(highestBid);
    }
}





