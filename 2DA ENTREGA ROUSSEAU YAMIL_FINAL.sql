DROP SCHEMA IF EXISTS UniversidadOFFSEC;
CREATE SCHEMA IF NOT EXISTS UniversidadOFFSEC;
USE UniversidadOFFSEC;


create table IF NOT EXISTS ESTUDIANTE(
idEstudiante VARCHAR(10) not null,
nombre VARCHAR(30) not null,
apellido VARCHAR(30) not null,
email VARCHAR(30) not null,
dni bigint(8),
telefono VARCHAR(15),
pais VARCHAR(25) not null,
ciudad VARCHAR(25) not null,
direccion VARCHAR(45) not null,
cp INT(8),
idTarjeta VARCHAR(10),
idMatricula varchar(10),
PRIMARY KEY (idEstudiante)
);

CREATE TABLE IF NOT EXISTS TARJETA(
idTarjeta VARCHAR(10) not null,
Descripcion varchar(30),
Numero bigint,
-- Expira varchar(10),
Expira date,
CVV varchar (4),
PRIMARY KEY (idTarjeta)
);


CREATE TABLE IF NOT EXISTS PROFESOR(
idProfesor VARCHAR(10) not null,
nombre VARCHAR(30) not null,
apellido VARCHAR(30) not null,
email VARCHAR(50) not null,
dni bigint(8) not null, -- longitud maxima 8 caracteres permite 0 inicial
Especialidad varchar(30),
createDate DATE ,
modifiedDate DATE ,
PRIMARY KEY (idProfesor)
);

CREATE TABLE IF NOT EXISTS CLASE_CURSADA(
idClase_Cursada int  not null,
idClase varchar(10) not null,
idCursada int not null,
PRIMARY KEY (idClase_Cursada)
);


CREATE TABLE IF NOT EXISTS CLASE (
    idClase VARCHAR(10) NOT NULL,
    dia DATE,
    horarioinicio INT,
    horariofinal INT,
    PRIMARY KEY (idClase)
);

CREATE TABLE IF NOT EXISTS CURSADA(
idCursada INT AUTO_INCREMENT not null,
idProfesor VARCHAR(10),
idAsignatura INT,
cant_clases INT,
PRIMARY KEY(idCursada)
);


CREATE TABLE IF NOT EXISTS ASIGNATURA(
idAsignatura INT AUTO_INCREMENT NOT NULL,
descripcion VARCHAR(100) NOT NULL,
idCarrera VARCHAR(10),
PRIMARY KEY (idAsignatura)
);


CREATE TABLE IF NOT EXISTS CARRERA(
idCarrera VARCHAR(10) NOT NULL,
nombre VARCHAR (50),
cant_Asignaturas INT,
PRIMARY KEY (idCarrera)
);


CREATE TABLE IF NOT EXISTS MATRICULA(
idMatricula varchar(10) NOT NULL,
CantCuotas INT ,
MatriculaCreada DATE not null,
MatriculaModificado DATE,
PRIMARY KEY (idMatricula)
);


-- tabla intermedia Matricula - Cuota
CREATE TABLE IF NOT EXISTS MATRICULA_CUOTA(
idMatriculaCuota int auto_increment not null,
idMatricula VARCHAR(10) NOT NULL,
idCuota int not null,
Estado VARCHAR(10),
PRIMARY KEY (idMatriculaCuota)
);


CREATE TABLE IF NOT EXISTS CUOTA (
    idCuota INT AUTO_INCREMENT NOT NULL,
    descripcion VARCHAR(30),
    monto DECIMAL(10,2),
    FechaVenc DATE,
    PRIMARY KEY (idCuota)
);

-- MODIFICACIONE AGREGANDO FOREIGN KEY A LAS TABLAS

ALTER TABLE ESTUDIANTE ADD CONSTRAINT fkidMatricula FOREIGN KEY(idMatricula) REFERENCES MATRICULA(idMatricula);
ALTER TABLE ESTUDIANTE ADD CONSTRAINT fkidTarjeta  FOREIGN KEY(idTarjeta) REFERENCES TARJETA(idTarjeta);

ALTER TABLE CLASE_CURSADA ADD CONSTRAINT fkidClase  FOREIGN KEY(idClase) REFERENCES CLASE(idClase);
ALTER TABLE CLASE_CURSADA ADD CONSTRAINT fkidCursada  FOREIGN KEY(idCursada) REFERENCES CURSADA(idCursada);

ALTER TABLE CURSADA ADD CONSTRAINT fkidProfesor FOREIGN KEY (idProfesor) REFERENCES PROFESOR(idProfesor);
ALTER TABLE CURSADA ADD CONSTRAINT fkidAsignatura FOREIGN KEY (idAsignatura) REFERENCES ASIGNATURA(idAsignatura);

ALTER TABLE ASIGNATURA ADD CONSTRAINT fkidCarrera FOREIGN KEY (idCarrera) REFERENCES CARRERA(idCarrera);

ALTER TABLE MATRICULA_CUOTA ADD CONSTRAINT fkidMatriculcta FOREIGN KEY (idMatricula) REFERENCES MATRICULA(idMatricula);
ALTER TABLE MATRICULA_CUOTA ADD CONSTRAINT fkidCuota FOREIGN KEY (idCuota) REFERENCES CUOTA(idCuota);







/*
Funciones

TRIGGERS
DROP TABLE IF EXISTS BITACORA_TRIGGER;
CREATE DATABASE BITACORA_TRIGGER;
USE BITACORA_TRIGGER;

*/

CREATE TABLE IF NOT EXISTS BITACORA(
idBitacora int auto_increment NOT null,
fecha date,
executeSQL varchar(2000),
reverseSQL varchar(2000),
PRIMARY KEY (idBitacora)
);

-- Trigger INSERT ESTUDIANTES

DELIMITER $$
CREATE TRIGGER AFTER_INSERT_ESTUDIANTES
AFTER INSERT ON ESTUDIANTE
FOR EACH ROW
BEGIN
	INSERT INTO BITACORA(fecha,executeSQL,reverseSQL)
    values(
		now(),
        concat("INSERT INTO Estudiante(idEstudiante,nombre,apellido,email,dni,telefono,pais,ciudad,direccion,cp) values(",new.idEstudiante,",""",new.nombre,""",""",new.apellido,""",""",new.email,""",",new.dni,",",new.telefono,",""",new.pais,""",""",new.ciudad,""",""",new.direccion,""",""",new.cp,""");"),
    	concat("DELETE FROM Estudiante where idalumno = ", NEW.idEstudiante,";")
	);
END;
$$
DELIMITER ;

-- Prueba de Trigger AFTER
insert into ESTUDIANTE(idEstudiante,nombre,apellido,email,dni,telefono,pais,ciudad,direccion,cp,idtarjeta,idMatricula) values 
('e0028','Magdalena','Salgado','salgado_magda@empresa.com',	16605875,03424692459,'	Argentina','Santa fe','Aristobulo del valle 6799',1846,'tar27','mat100028');


/*
-- IMPORTACIONES
-- show variables like "secure_file_priv";
*/

-- Importacion de la tabla estudiante

LOAD DATA INFILE "../uploads/dbEstudiante.csv" INTO TABLE ESTUDIANTE
FIELDS TERMINATED BY ','
IGNORE 1 LINES;



-- Importacion de la tabla tarjetas
LOAD DATA INFILE "../uploads/dbTarjeta.csv" INTO TABLE TARJETA
FIELDS TERMINATED BY ','
IGNORE 1 LINES;
-- SELECT * FROM TARJETA;

-- Importacion de la tabla profesor
LOAD DATA INFILE "../uploads/dbProfesor.csv" INTO TABLE PROFESOR
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

-- select * from PROFESOR;

LOAD DATA INFILE "../uploads/dbClaseCursada.csv" INTO TABLE CLASE_CURSADA
FIELDS TERMINATED BY ','
IGNORE 1 LINES;
-- select * from CLASE_CURSADA;

-- CLASE
LOAD DATA INFILE "../uploads/dbClase.csv" INTO TABLE CLASE
FIELDS TERMINATED BY ','
IGNORE 1 LINES;
-- select * from CLASE;

-- CURSADA
LOAD DATA INFILE "../uploads/dbCursada.csv" INTO TABLE CURSADA
FIELDS TERMINATED BY ','
IGNORE 1 LINES;
-- select * from CURSADA;

LOAD DATA INFILE "../uploads/dbAsignatura.csv" INTO TABLE ASIGNATURA
FIELDS TERMINATED BY ','
IGNORE 1 LINES;
-- select * from ASIGNATURA;

LOAD DATA INFILE "../uploads/dbCarrera.csv" INTO TABLE CARRERA
FIELDS TERMINATED BY ','
IGNORE 1 LINES;
-- select * from CARRERA;

-- Matricula
LOAD DATA INFILE "../uploads/dbMatricula.csv" INTO TABLE MATRICULA
FIELDS TERMINATED BY ','
IGNORE 1 LINES;
-- select * from MATRICULA;

-- CUOTA
LOAD DATA INFILE "../uploads/dbCuota.csv" INTO TABLE CUOTA
FIELDS TERMINATED BY ','
IGNORE 1 LINES;
-- select * from CUOTA;


-- funcion calcular pago anual
Delimiter //
-- DROP FUNCTION if exists FN_CALCULAR_PAGO_ANUAL;

CREATE FUNCTION FN_CALCULAR_PAGO_ANUAL (monto INT) 
RETURNS FLOAT
DETERMINISTIC
BEGIN
	DECLARE RESULTADO FLOAT; 
    SET meses = 12;
    SET RESULTADO = (meses * monto);
    RETURN RESULTADO;
END 
Delimiter ;

