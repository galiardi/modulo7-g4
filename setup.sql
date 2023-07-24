CREATE DATABASE banco;

USE banco;

CREATE TABLE cuentas(
  id_cuenta INT NOT NULL AUTO_INCREMENT,
  saldo DECIMAL CHECK (saldo >= 0),
  PRIMARY KEY (id_cuenta)
);

CREATE TABLE transacciones(
  id_transaccion INT NOT NULL AUTO_INCREMENT,
  descripcion VARCHAR(50),
  fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  monto DECIMAL,
  id_cuenta INT NOT NULL,
  PRIMARY KEY (id_transaccion),
  FOREIGN KEY (id_cuenta) REFERENCES cuentas(id_cuenta)
);

delimiter **
    create procedure transfer_(
        in id_origen varchar(100),
        in id_destino varchar(100),
        in cantidad decimal
    )
    
    begin
    
    set @saldo_origen = (select saldo from cuentas where id_cuenta=id_origen);
    set @saldo_destino = (select saldo from cuentas where  id_cuenta=id_destino);
    set @nuevo_saldo_origen = @saldo_origen - cantidad;
    set @nuevo_saldo_destino = @saldo_destino + cantidad;

    UPDATE cuentas SET saldo = @nuevo_saldo_origen WHERE id_cuenta = id_origen;
    UPDATE cuentas SET saldo = @nuevo_saldo_destino WHERE id_cuenta = id_destino;
    
    SELECT id_cuenta as cuenta_origen, saldo from cuentas WHERE id_cuenta=id_origen
    UNION
    SELECT id_cuenta as cuenta_destino, saldo from cuentas WHERE id_cuenta=id_destino;
    end **
delimiter ;
