// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title BilleteraElectronica
 * @dev Contrato principal para gestionar la Billetera Electrónica basada en CBDC.
 */
contract Storage is Ownable {

     // Variables de estado
     mapping(address => uint256) private balances;
     IERC20 public cbdcToken; // Token representativo de la CBDC

     // Eventos
     event Deposit(address indexed sender, uint256 amount);
     event Withdrawal(address indexed recipient, uint256 amount);
     event Transfer(address indexed from, address indexed to, uint256 amount);

     constructor(IERC20 _cbdcToken) {
         cbdcToken = _cbdcToken;
     }

     /**
     * @dev Función para depositar fondos en la billetera.
     */
    function deposit(uint256 _amount) external {
      require(_amount > 0, "El monto debe ser mayor a 0");
      require(cbdcToken.transferFrom(msg.sender, address(this), _amount), "Transferencia fallida");
      balances[msg.sender] += _amount;
      emit Deposit(msg.sender, _amount);
     }

    /**
     * @dev Función para retirar fondos de la billetera.
     * @param _amount El monto a retirar.
     */
     function withdraw(uint256 _amount) external {
         require(balances[msg.sender] >= _amount, "Saldo insuficiente");
         balances[msg.sender] -= _amount;
         require(cbdcToken.transfer(msg.sender, _amount), "Transferencia fallida");
         emit Withdrawal(msg.sender, _amount);
     }

     /**
     * @dev Función para transferir fondos entre usuarios.
     * @param _to La dirección del destinatario.
     * @param _amount El monto a transferir.
     */
    function transfer(address _to, uint256 _amount) external {
     require(balances[msg.sender] >= _amount, "Saldo insuficiente");
     require(_to != address(0), "Direccon invalida");
     balances[msg.sender] -= _amount;
     balances[_to] += _amount;
     require(cbdcToken.transfer(_to, _amount), "Transferencia fallida");
     emit Transfer(msg.sender, _to, _amount);
     }

     /**
     * @dev Función para consultar el saldo de una dirección.
     * @param _owner La dirección del propietario.
     * @return El saldo de la dirección.
     */
     function balanceOf(address _owner) external view returns (uint256) {
     return balances[_owner];
     }

     /**
     * @dev Función receive para aceptar pagos.
     */
     receive() external payable {
     revert("No se aceptan pagos en ETH");
     }

     /**
     * @dev Función fallback.
     */
     fallback() external payable {
     revert("Funccion no permitida");
     }
}