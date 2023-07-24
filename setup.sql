CREATE DATABASE banco;

USE banco;

CREATE TABLE cuentas(
  id_cuenta INT NOT NULL AUTO_INCREMENT,
  saldo DECIMAL CHECK (saldo >= 0),
  PRIMARY KEY (id_cuenta)
);

CREATE TABLE transacciones(
  id_transaccion INT NOT NULL AUTO_INCREMENT,
  fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  monto DECIMAL NOT NULL,
  descripcion VARCHAR(50),
  id_cuenta_origen INT NOT NULL,
  id_cuenta_destino INT NOT NULL,
  PRIMARY KEY (id_transaccion),
  FOREIGN KEY (id_cuenta_origen) REFERENCES cuentas(id_cuenta),
  FOREIGN KEY (id_cuenta_destino) REFERENCES cuentas(id_cuenta)
);

-- Procedimiento almacenado para transferir
delimiter **
    create procedure transfer_(
        in id_origen INT,
        in id_destino INT,
        in cantidad DECIMAL,
        descripcion VARCHAR(50)
    )
    
    begin
    
    set @saldo_origen = (select saldo from cuentas where id_cuenta=id_origen);
    set @saldo_destino = (select saldo from cuentas where  id_cuenta=id_destino);
    set @nuevo_saldo_origen = @saldo_origen - cantidad;
    set @nuevo_saldo_destino = @saldo_destino + cantidad;

    UPDATE cuentas SET saldo = @nuevo_saldo_origen WHERE id_cuenta = id_origen;
    UPDATE cuentas SET saldo = @nuevo_saldo_destino WHERE id_cuenta = id_destino;

    INSERT INTO transacciones (monto, descripcion, id_cuenta_origen, id_cuenta_destino) VALUES (cantidad, descripcion, id_origen, id_destino);
    
    SELECT * FROM transacciones WHERE id_transaccion = LAST_INSERT_ID();
    end **
delimiter ;
