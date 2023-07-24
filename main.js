import { connection } from './db.js';

const [command, ...args] = process.argv.slice(2);

switch (command) {
  case 'agregar-cuenta':
    await addAccount(args);
    break;

  case 'obtener-saldo':
    await getSaldo(args);
    break;

  case 'transferir':
    await transfer(args);
    break;

  case 'mostrar-transacciones':
    await showTransactions(args);
    break;

  case undefined:
    console.log('Debe ingresar un comando.');
    break;

  default:
    console.log('El comando ingresado no existe.');
    break;
}

connection.end();

async function addAccount([saldo]) {
  if (!saldo) return console.log('Debe ingresar un saldo inicial');

  try {
    const query = `
    INSERT INTO cuentas (saldo) VALUES (?)
  `;
    const [rows] = await connection.execute(query, [saldo]);
    console.log(rows);
  } catch (error) {
    console.log(error);
  }
}

async function getSaldo([id_cuenta]) {
  if (!id_cuenta) return console.log('Debe ingresar un id de cuenta');

  try {
    const [rows] = await connection.execute(
      'SELECT saldo FROM cuentas WHERE id_cuenta = ?',
      [id_cuenta]
    );

    if (!rows.length) return console.log('El numero de cuenta proporcionado no existe.');

    console.log(rows[0].saldo);
  } catch (error) {
    console.log(error);
  }
}

async function transfer([sourceAccount, destinationAccount, quantity]) {
  await connection.beginTransaction();

  try {
    const [result] = await connection.execute('CALL transfer_(?, ?, ?)', [
      sourceAccount,
      destinationAccount,
      quantity,
    ]);
    console.table(result[0]);

    await connection.commit();
  } catch (error) {
    await connection.rollback();
    if (error.code === 'ER_CHECK_CONSTRAINT_VIOLATED')
      return console.log('Saldo insuficiente');
    console.log(error);
  }
}

async function showTransactions([id_cuenta]) {
  if (!id_cuenta) return console.log('Debe proporcionar un id de cuenta.');

  try {
    const query = `
    SELECT * FROM transacciones
    WHERE id_cuenta = ?;
  `;

    const [rows] = await connection.execute(query, [id_cuenta]);

    if (!rows.length) return console.log('La cuenta consultada no posee transacciones.');

    console.log(rows);
  } catch (error) {
    console.log(error);
  }
}

/*
Utiliza los argumentos de la línea de comando para definir los valores que usarán tus consultas SQL.
Consideraciones generales

1. Crear una función asíncrona que registre una nueva transacción utilizando valores ingresados como
argumentos en la línea de comando. Debe mostrar por consola la última transacción realizada.
2. Realizar una función asíncrona que consulte la tabla de transacciones y retorne máximo 10 registros de una
cuenta en específico. Debes usar cursores para esto.
3. Realizar una función asíncrona que consulte el saldo de una cuenta y que sea ejecutada con valores
ingresados como argumentos en la línea de comando. Debes usar cursores para esto.
4. En caso de haber un error en la transacción, se debe retornar el error por consola.
*/
