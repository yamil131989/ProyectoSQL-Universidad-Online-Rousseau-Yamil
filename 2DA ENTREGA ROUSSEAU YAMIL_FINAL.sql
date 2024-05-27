DROP SCHEMA IF EXISTS UniversidadOFFSEC1;
CREATE SCHEMA IF NOT EXISTS UniversidadOFFSEC1;
USE UniversidadOFFSEC1;

-- drop table ESTUDIANTE;
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
fkidTarjeta VARCHAR(10),
fkidMatricula varchar(10),
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
fkidClase varchar(10) not null, 
fkidCursada int not null,
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
fkidProfesor VARCHAR(10),
fkidAsignatura INT,
cant_clases INT,
fkidEstudiante VARCHAR(10),
PRIMARY KEY(idCursada)
);


CREATE TABLE IF NOT EXISTS ASIGNATURA(
idAsignatura INT AUTO_INCREMENT NOT NULL,
descripcion VARCHAR(100) NOT NULL,
fkidCarrera VARCHAR(10),
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

SELECT * FROM MATRICULA;

-- tabla intermedia Matricula - Cuota
CREATE TABLE IF NOT EXISTS MATRICULA_CUOTA(
idMatriculaCuota int auto_increment not null,
fkidMatricula VARCHAR(10) NOT NULL,
fkidCuota int not null,
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

CREATE TABLE IF NOT EXISTS EstudianteCursada (   -- NOTA
	record int auto_increment not null,
	idEstudiante varchar(10) not null,
	idCursada int not null,
	Nota1 int ,
	Nota2 INT,
	Final INT,
	primary key (record)
);
SELECT * FROM ESTUDIANTE;

/*-- --------------------------------------------------------------------------------------
-- IMPORTACION DE LAS TABLAS : Es recomendable que se realicen las importaciones antes de seguir 
-- con el script
*/-- --------------------------------------------------------------------------------------


/*-- --------------------------------------------------------------------------------------
-- MODIFICACIONES AGREGANDO FOREIGN KEY A LAS TABLAS
*/-- --------------------------------------------------------------------------------------

ALTER TABLE EstudianteCursada ADD CONSTRAINT fk_idEstudianteEst FOREIGN KEY(idEstudiante) REFERENCES ESTUDIANTE(idEstudiante);
ALTER TABLE EstudianteCursada ADD CONSTRAINT fk_idCursadaEst FOREIGN KEY(idCursada) REFERENCES CURSADA(idCursada);


ALTER TABLE ESTUDIANTE ADD CONSTRAINT fk_idMatricula FOREIGN KEY(fkidMatricula) REFERENCES MATRICULA(idMatricula);
ALTER TABLE ESTUDIANTE ADD CONSTRAINT fk_idTarjeta  FOREIGN KEY(fkidTarjeta) REFERENCES TARJETA(idTarjeta);

ALTER TABLE CLASE_CURSADA ADD CONSTRAINT fk_idClase  FOREIGN KEY(fkidClase) REFERENCES CLASE(idClase);
ALTER TABLE CLASE_CURSADA ADD CONSTRAINT fk_idCursada  FOREIGN KEY(fkidCursada) REFERENCES CURSADA(idCursada); 

ALTER TABLE CURSADA ADD CONSTRAINT fk_idProfesor FOREIGN KEY (fkidProfesor) REFERENCES PROFESOR(idProfesor);
ALTER TABLE CURSADA ADD CONSTRAINT fk_idAsignatura FOREIGN KEY (fkidAsignatura) REFERENCES ASIGNATURA(idAsignatura);



ALTER TABLE MATRICULA_CUOTA ADD CONSTRAINT fk_idMatriculcta FOREIGN KEY (fkidMatricula) REFERENCES MATRICULA(idMatricula);
ALTER TABLE MATRICULA_CUOTA ADD CONSTRAINT fk_idCuota FOREIGN KEY (fkidCuota) REFERENCES CUOTA(idCuota);

-- ALTER TABLE ASIGNATURA ADD CONSTRAINT fk_idCarreraAsig FOREIGN KEY (fkidCarrera) REFERENCES CARRERA(idCarrera);


/*-- --------------------------------------------------------------------------------------
-- TRIGGERS
*/-- --------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Logger(
idRegistro int auto_increment NOT null,
fecha date,
executeSQL varchar(2000),
PRIMARY KEY (idRegistro)
);

-- TRIGGER INSERT ERROR: Proporciona un mensaje de error al ingresar un registro con valor p0009
DELIMITER //
CREATE TRIGGER PROFESOR_INSERT_ERROR0 BEFORE INSERT ON PROFESOR
FOR EACH ROW
IF NEW.idProfesor = 'p0009' then SIGNAL SQLSTATE '50001' SET MESSAGE_TEXT = 'Debe ser aprobado por el consejo JEDI.';
END IF; //
DELIMITER ;
-- Prueba de trigger
-- insert into PROFESOR VALUES ('p0009','Abc','Def','ghij@gmail.com',12123123,'NULL','2024-05-21','2024-05-21');
-- select * from profesor;

-- TRIGGER BEFORE : Registra a la TABLA BITACORA los valores de insercion de un nuevo registro a la tabla ESTUDIANTES
DELIMITER $$
CREATE TRIGGER BEFORE_INSERT_ESTUDIANTES
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



-- CREACION DE LA TABLA BITACORA:

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
insert into ESTUDIANTE(idEstudiante,nombre,apellido,email,dni,telefono,pais,ciudad,direccion,cp) values 
('e0028','Magdalena','Salgado','salgado_magda@empresa.com',	16605875,03424692459,'	Argentina','Santa fe','Aristobulo del valle 6799',1846);
SELECT * FROM ESTUDIANTE;

/*-- --------------------------------------------------------------------------------------
-- VISTAS
*/-- --------------------------------------------------------------------------------------

-- 1 BUSCO LOS ESTUDIANTES QUE ESTAN CURSANDO  Pentesting (asignatura = 6001)

CREATE OR REPLACE VIEW VW_PENTESTING AS (
SELECT nombre, apellido,email FROM Estudiante 
JOIN estudiantecursada join cursada 
on cursada.idCursada = estudiantecursada.idCursada
and Estudiante.idEstudiante = estudiantecursada.idEstudiante
WHERE fkidAsignatura= 6001
);

SELECT * FROM VW_PENTESTING;

-- 2 BUSCO LOS ESTUDIANTES QUE TIENEN POR locacion otras provicias
CREATE OR REPLACE VIEW VW_EstudianteInterior AS (
SELECT nombre, apellido,email FROM Estudiante 
where ciudad not like '%CABA%'
);
select * from VW_EstudianteInterior;

-- 3 BUSCO LOS Profesores que tienen clase con turno noche 20:30 a 22:30

CREATE OR REPLACE VIEW VW_TURNONOCHE as(
SELECT distinct nombre, apellido, especialidad FROM Profesor
JOIN cursada 
on idprofesor = fkidprofesor
join clase_cursada 
on idcursada = fkidcursada
join clase 
on idclase = fkidclase
WHERE horariofinal = 2230
);
select * from VW_TURNONOCHE;

-- 4 BUSCO ver los estudiantes que tienen clase con turno tarde 18:30 a 20:30 de orden descendente ARREGLAR
CREATE OR REPLACE VIEW VW_TURNOTARDE as(
SELECT distinct nombre, apellido, email FROM Estudiante
join estudiantecursada
on estudiantecursada.idestudiante = estudiante.idEstudiante
JOIN cursada 
on cursada.idCursada = estudiantecursada.idCursada 
join clase_cursada 
on idcursada = fkidcursada
join clase 
on idclase = fkidclase
WHERE horariofinal = 2030
);

-- 5 BUSCO ver los asignaturas de forma descendente que tienen alumnos cursando
CREATE OR REPLACE VIEW VW_ASIGNATURAS_CON_ALUMNOS as(
select descripcion from asignatura 
join Cursada
on idasignatura = fkidasignatura
where cant_clases > 3 order by descripcion ASC
);
select * from VW_ASIGNATURAS_CON_ALUMNOS;

/*
Solucion de problema de importacion por script
-- show variables like "secure_file_priv";
Recomendacion importar por archivo externo
*/

/*-- --------------------------------------------------------------------------------------
-- FUNCIONES
*/-- --------------------------------------------------------------------------------------

-- FUNCION PAGO ANUAL

Delimiter //

DELIMITER $$
CREATE FUNCTION FN_CALCULAR_PAGO_ANUAL(p_cuotas int, p_monto float) 
RETURNS FLOAT
DETERMINISTIC
BEGIN
	DECLARE V_RESULTADO FLOAT; 
    SET V_RESULTADO = (p_cuotas * p_monto);
    RETURN  V_RESULTADO;
END $$
Delimiter ;
select FN_CALCULAR_PAGO_ANUAL(12, 15000);

-- FUNCION CALCULAR PROMEDIO
DELIMITER $$
CREATE FUNCTION FN_PROMEDIO1(id varchar(10))
RETURNS FLOAT
DETERMINISTIC
BEGIN
DECLARE V_PROMEDIO FLOAT; 
DECLARE V_NOTA1 INT; 
DECLARE V_NOTA2 INT;
DECLARE V_NOTA3 INT;

    SET V_NOTA1 = (SELECT Nota1 from ESTUDIANTECURSADA WHERE idEstudiante = id);
    SET V_NOTA2 = (SELECT Nota2 from ESTUDIANTECURSADA WHERE idEstudiante = id);
    SET V_NOTA3 = (SELECT FINAL from ESTUDIANTECURSADA WHERE idEstudiante = id);
    SET V_PROMEDIO = (V_NOTA1+V_NOTA2+V_NOTA3) /3;
RETURN  V_PROMEDIO;
END $$
Delimiter ;
-- SELECT Nota1 from ESTUDIANTECURSADA WHERE idEstudiante = 'e0001';
select FN_PROMEDIO1('e0003');

/*-- --------------------------------------------------------------------------------------
-- STORE PROCEDURES
*/-- --------------------------------------------------------------------------------------

-- 
-- 1 Store procedure que traiga las notas de los estudiantes por id
-- DROP PROCEDURE SP_Estudiantes_inscriptos;
Delimiter $$
CREATE PROCEDURE SP_Estudiante_inscripto(IN P_IDEstudiante varchar(10) ,
														 OUT P_NOMBRE VARCHAR(30),
                                                         OUT P_APELLIDO VARCHAR(30),
                                                         OUT P_NOTA1 int,
                                                         OUT P_NOTA2 INT,
                                                         OUT P_NOTA3 INT)

DETERMINISTIC
BEGIN
SELECT  nombre,
		apellido,
        estudiantecursada.Nota1,
        estudiantecursada.Nota2,
        estudiantecursada.Final
        INTO 
        P_NOMBRE,
        P_APELLIDO,
        P_NOTA1,
        P_NOTA2,
        P_NOTA3
FROM Estudiante  
join estudiantecursada
on  Estudiante.idEstudiante= estudiantecursada.idEstudiante 
where Estudiante.idEstudiante = P_IDEstudiante LIMIT 1;
END $$
Delimiter ;
-- ---- Prueba de datos
-- CALL SP_Estudiante_inscripto('e0027',@NOMBRE,@APELLIDO,@NOTA1,@NOTA2,@NOTA3);
-- SELECT @NOMBRE,@APELLIDO,@NOTA1,@NOTA2,@NOTA3;
-- ---- 

-- 2 STORE PROCEDURE traer el nombre de asignatura que contenga la palabra 

delimiter //
CREATE PROCEDURE SP_Asignatura_nombre5(IN P_PALABRA varchar(30),
										 OUT P_ASIGNATURA VARCHAR(100))
BEGIN
SELECT descripcion
		into
        P_ASIGNATURA
FROM Asignatura
where Asignatura.descripcion like P_PALABRA limit 1;
end //
delimiter ;
-- Prueba de datos 
-- call SP_Asignatura_nombre5('%Red%',@Asignatura);
-- select @Asignatura;
-- 
