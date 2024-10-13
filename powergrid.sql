/*
 * Copyright (c) 2024 Giannuzzi Riccardo, Biribò Francesco, Palumbo Dario
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

/*----------------------------------------------*\
|    Progetto Rete Elettrica                     |
|                                                |
|    Cognome: Giannuzzi     Nome: Riccardo       |
|    Cognome: Biribò        Nome: Francesco      |
|    Cognome: Palumbo       Nome: Dario          |
|                                                |
\*----------------------------------------------*/



/*------------------------*\
   CREAZIONE BASE DI DATI
\*------------------------*/

DROP DATABASE IF EXISTS rete_elettrica;
CREATE DATABASE IF NOT EXISTS rete_elettrica;
USE rete_elettrica;



/*-------------------*\
   CREAZIONE TABELLE
\*-------------------*/

DROP TABLE IF EXISTS Rendimento;
DROP TABLE IF EXISTS Generatore;
DROP TABLE IF EXISTS Fornitura;
DROP TABLE IF EXISTS Consumo;
DROP TABLE IF EXISTS Responsabile;
DROP TABLE IF EXISTS Bolletta;
DROP TABLE IF EXISTS Contratto;
DROP TABLE IF EXISTS Immobile;
DROP TABLE IF EXISTS Intestatario;
DROP TABLE IF EXISTS Produttore;
DROP TABLE IF EXISTS Distributore;

CREATE TABLE IF NOT EXISTS Intestatario(
    CF CHAR(16) PRIMARY KEY,
    nome VARCHAR(25) NOT NULL,
    cognome VARCHAR(25) NOT NULL,
    data_nascita DATE NOT NULL
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS Immobile(
    id_comune CHAR(4),
    id_unita_immobiliare VARCHAR(15),
    tipo_abitazione ENUM('abitazione', 'azienda') NOT NULL,
    via VARCHAR(25) NOT NULL,
    civico VARCHAR(5) NOT NULL,
    CAP CHAR(5) NOT NULL,

    PRIMARY KEY(id_comune, id_unita_immobiliare)
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS Consumo(
    id_comune CHAR(4),
    id_unita_immobiliare VARCHAR(15),
    data DATE,
    kWh DECIMAL(8,3) NOT NULL,

    PRIMARY KEY(id_comune, id_unita_immobiliare, data),
    FOREIGN KEY(id_comune, id_unita_immobiliare) REFERENCES Immobile(id_comune, id_unita_immobiliare) ON DELETE NO ACTION
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS Produttore(
    p_iva CHAR(11) PRIMARY KEY,
    nome VARCHAR(30) NOT NULL
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS Generatore(
    id_generatore INT AUTO_INCREMENT PRIMARY KEY,
    produttore CHAR(11),
    data_installazione DATE NOT NULL,
    tipo_generatore ENUM('eolico', 'fotovoltaico', 'carbone', 'gas') NOT NULL,

    FOREIGN KEY(produttore) REFERENCES Produttore(p_iva) ON DELETE NO ACTION
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS Rendimento(
    generatore INT,
    data DATE,
    kWh DECIMAL(8,3) NOT NULL,

    PRIMARY KEY(generatore, data),
    FOREIGN KEY(generatore) REFERENCES Generatore(id_generatore) ON DELETE NO ACTION
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS Distributore(
    p_iva CHAR(11) PRIMARY KEY,
    nome VARCHAR(30) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    email VARCHAR(50) NOT NULL
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS Fornitura(
    produttore CHAR(11),
    distributore CHAR(11),
    data DATE,
    kWh DECIMAL(8,3) NOT NULL,
    prezzo DECIMAL(10,2) NOT NULL,

    PRIMARY KEY(produttore, distributore, data),
    FOREIGN KEY(produttore) REFERENCES Produttore(p_iva) ON DELETE NO ACTION,
    FOREIGN KEY(distributore) REFERENCES Distributore(p_iva) ON DELETE NO ACTION
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS Contratto(
    id_contratto INT AUTO_INCREMENT PRIMARY KEY,
    distributore CHAR(11),
    id_comune CHAR(4),
    id_unita_immobiliare VARCHAR(15),
    tariffa DECIMAL(3,2) NOT NULL,
    limite_kW DECIMAL(6,3) NOT NULL,
    data_stipulazione DATE NOT NULL,
    data_scadenza DATE NOT NULL,

    FOREIGN KEY(distributore) REFERENCES Distributore(p_iva) ON DELETE NO ACTION,
    FOREIGN KEY(id_comune, id_unita_immobiliare) REFERENCES Immobile(id_comune, id_unita_immobiliare) ON DELETE NO ACTION
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS Bolletta(
    id_bolletta INT AUTO_INCREMENT PRIMARY KEY,
    contratto INT,
    costo DECIMAL(6,2) NOT NULL,
    data_pagamento DATE,
    data_scadenza DATE NOT NULL,
    data_inizio DATE NOT NULL,
    data_fine DATE NOT NULL,

    FOREIGN KEY(contratto) REFERENCES Contratto(id_contratto) ON DELETE NO ACTION
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS Responsabile(
    id_contratto INT,
    CF CHAR(16),

    PRIMARY KEY(id_contratto, CF),
    FOREIGN KEY(id_contratto) REFERENCES Contratto(id_contratto) ON DELETE NO ACTION,
    FOREIGN KEY(CF) REFERENCES Intestatario(CF) ON DELETE NO ACTION
) ENGINE=INNODB;



/*---------------------*\
   POPOLAMENTO TABELLE
\*---------------------*/
SET GLOBAL local_infile = 1; # Togliere il commento per usare LOAD DATA LOCAL INFILE
# Inserire il proprio path assoluto per ogni comando LOAD DATA LOCAL, usando come riferimento il nome del file indicato
# Per esempio, considerando il file "Intestatari.txt" 
#   Su windows, sostituire con "<Disco>:\\Path\\del\\folder\\Intestatari.txt"
#   Su un sistema Unix-like, sostituire con '/path/del/folder/Intestatari.txt'

INSERT INTO Produttore VALUES
    ('00905811006', 'Eni Plenitude'),
    ('08371542908', 'EleProducer'),
    ('06543210789', 'VoltaEnergia'),
    ('04785920361', 'EnergiaPiù'),
    ('03871920485', 'EcoEnergia');

INSERT INTO Distributore VALUES
    ('00905811006', 'Eni Plenitude', '39800900700', 'commerciale@enigaseluce.com'),
    ('15844561009', 'Enel Energia', '39800900860', 'enelenergia@enel.com'),
    ('08600990017', 'EnerGrid', '39800584585', 'info@energrid.it');

LOAD DATA LOCAL INFILE "Intestatari.txt" INTO TABLE Intestatario 
        FIELDS TERMINATED BY ", "
        LINES TERMINATED BY "\n"
        IGNORE 3 ROWS;

LOAD DATA LOCAL INFILE "Immobili.txt" INTO TABLE Immobile 
        FIELDS TERMINATED BY ", "
        LINES TERMINATED BY "\n"
        IGNORE 3 ROWS; 

LOAD DATA LOCAL INFILE "Forniture.txt" INTO TABLE Fornitura 
        FIELDS TERMINATED BY ", "
        LINES TERMINATED BY "\n"
        IGNORE 3 ROWS; 

LOAD DATA LOCAL INFILE "Generatori.txt" INTO TABLE Generatore 
        FIELDS TERMINATED BY ", "
        LINES TERMINATED BY "\n"
        IGNORE 3 ROWS;

LOAD DATA LOCAL INFILE "Rendimenti.txt" INTO TABLE Rendimento 
        FIELDS TERMINATED BY ", "
        LINES TERMINATED BY "\n"
        IGNORE 3 ROWS;

LOAD DATA LOCAL INFILE "Contratti.txt" INTO TABLE Contratto 
        FIELDS TERMINATED BY ", "
        LINES TERMINATED BY "\n"
        IGNORE 3 ROWS;

LOAD DATA LOCAL INFILE "Bollette.txt" INTO TABLE Bolletta 
        FIELDS TERMINATED BY ", "
        LINES TERMINATED BY "\n"
        IGNORE 3 ROWS;

LOAD DATA LOCAL INFILE "Consumi.txt" INTO TABLE Consumo 
        FIELDS TERMINATED BY ", "
        LINES TERMINATED BY "\n"
        IGNORE 3 ROWS;

INSERT INTO Responsabile VALUES 
    (1, 'RSSMRA85M01F205Z'),
    (2, 'VRDLGU90A01H501X'),
    (3, 'BNCLRA85M01G273S'),
    (4, 'FRNDRN70D15F205S'),
    (5, 'MNISRV80C41H501Z'),
    (6, 'RCCGPP75M01G273U'),
    (7, 'BLLFNC82T30E463D'),
    (8, 'BLLFNC82T30E463D'),
    (9, 'BLLFNC82T30E463D'),
    (9, 'SMTMRC85A41G273K'),
    (10, 'SMTMRC85A41G273K'),
    (11, 'SMTMRC85A41G273K');



/*---------*\
   TRIGGER
\*---------*/

# 1: Il limite di kW per gli immobili deve essere maggiore di 0
# 2: La data di stipulazione di un contatto deve precedere la data di scadenza e non deve superare la data attuale
#   In altre parole deve valere la seguente disequazione: data_stipulazione <= data_attuale E data_stipulazione < data_scadenza
# 3: Per un immobile non è ammesso più di un contratto attivo. Tuttavia è possibile aggiungere contratti scaduti anche se ha già un contratto attivo
# I controlli sono stati fatti in ordine di complessita
DROP TRIGGER IF EXISTS validita_contratto;
DELIMITER //
CREATE TRIGGER validita_contratto
BEFORE INSERT ON Contratto
FOR EACH ROW
BEGIN
    DECLARE sovrapposizioni INT;
    DECLARE data_attuale DATE;

    # 1: Controlliamo la validita del limite_kw
    IF NEW.limite_kW <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il limite di kW deve essere maggiore di 0';
    ELSE
        # 2: Controlliamo se data_stipulazione <= data_attuale e data_stipulazione < data_scadenza
            SELECT CURDATE() INTO data_attuale;

        IF NOT (NEW.data_stipulazione <= data_attuale AND NEW.data_stipulazione < NEW.data_scadenza) THEN
            SIGNAL SQLSTATE '45001'
            SET MESSAGE_TEXT = 'Le date non rispettano la condizione: data_stipulazione <= data_attuale AND data_stipulazione < data_scadenza';
        ELSE
            # 3: Controlliamo la sovrapposizione dei contratti
            SELECT COUNT(*) INTO sovrapposizioni FROM Contratto 
                WHERE (Contratto.id_comune = NEW.id_comune AND Contratto.id_unita_immobiliare = NEW.id_unita_immobiliare)
                AND (
                    (NEW.data_stipulazione BETWEEN Contratto.data_stipulazione AND Contratto.data_scadenza) OR
                    (NEW.data_scadenza BETWEEN Contratto.data_stipulazione AND Contratto.data_scadenza) OR
                    (Contratto.data_stipulazione BETWEEN NEW.data_stipulazione AND NEW.data_scadenza) OR
                    (Contratto.data_scadenza  BETWEEN NEW.data_stipulazione AND NEW.data_scadenza)
                );
            IF sovrapposizioni > 0 THEN
                SIGNAL SQLSTATE '45002'
                SET MESSAGE_TEXT = 'Il contratto copre il periodo di riferimento di un altro contratto';
            END IF;
        END IF;
    END IF;
END //
DELIMITER ;

# 1: Il consumo giornaliero di un immobile deve essere maggiore o uguale a 0
# 2: La data del consumo non puo superare la data attuale
# 3: Il totale dei consumi di una giornata, degli immobili coperti da un certo distributore, non puo superare la somma di energia che ha ricevuto tale distributore quel giorno
# I controlli sono stati fatti in ordine di complessita
DROP TRIGGER IF EXISTS validita_consumo;
DELIMITER //
CREATE TRIGGER validita_consumo
BEFORE INSERT ON Consumo
FOR EACH ROW
BEGIN
    DECLARE data_attuale DATE;
    DECLARE consumo_giornaliero DECIMAL(10,3) DEFAULT 0.000;
    DECLARE fornitura_giornaliera DECIMAL(10,3) DEFAULT 0.000;
    DECLARE distributore CHAR(11);

    # 1: Controlliamo la validità dei kWh
    IF NEW.kWh < 0 THEN
        SIGNAL SQLSTATE '45003'
        SET MESSAGE_TEXT = 'Il consumo di un immobile deve essere maggiore o uguale a 0';
    ELSE
        # 2: Controlliamo che non sia una data futura
            SELECT CURDATE() INTO data_attuale;
            IF NEW.data > data_attuale THEN
                SIGNAL SQLSTATE '45004'
                SET MESSAGE_TEXT = 'La data del consumo non puo superare la data attuale';
            ELSE
                # 3: Se i kWh e la datasono corretti, controlliamo se è coerente con le forniture di quel distributore per quel giorno
                SELECT Distributore.p_iva INTO distributore FROM Distributore 
                    JOIN Contratto ON Distributore.p_iva = Contratto.distributore
                    WHERE Contratto.id_comune = NEW.id_comune AND Contratto.id_unita_immobiliare = NEW.id_unita_immobiliare
                    AND Contratto.data_scadenza > CURDATE();
                
                SELECT SUM(Consumo.kWh) INTO consumo_giornaliero FROM Consumo 
                    JOIN Immobile ON (Consumo.id_comune = Immobile.id_comune AND Consumo.id_unita_immobiliare = Immobile.id_unita_immobiliare)
                    JOIN Contratto ON (Immobile.id_comune = Contratto.id_comune AND Immobile.id_unita_immobiliare = Contratto.id_unita_immobiliare)
                    WHERE Contratto.data_scadenza > CURDATE() AND Contratto.distributore = distributore AND Consumo.data = NEW.data;
                
                SELECT SUM(Fornitura.kWh) INTO fornitura_giornaliera FROM Fornitura
                    WHERE Fornitura.data = NEW.data AND Fornitura.distributore = distributore;
                
                IF (consumo_giornaliero + NEW.kWh) > fornitura_giornaliera THEN
                    SIGNAL SQLSTATE '45005'
                    SET MESSAGE_TEXT = 'Il consumo supererebbe la fornitura del distributore';
                END IF;
            END IF;
    END IF;
END //
DELIMITER ;

# 1: Il rendimento giornaliero di un generatore deve essere maggiore o uguale a 0
# 2: La data del rendimento non puo superare la data attuale
# 3: Non si puo registrare un rendimento per un generatore se la data del rendimento precede la data di installazione del generatore
# I controlli sono stati fatti in ordine di complessita
DROP TRIGGER IF EXISTS validita_rendimento;
DELIMITER //
CREATE TRIGGER validita_rendimento
BEFORE INSERT ON Rendimento
FOR EACH ROW
BEGIN
    DECLARE data_attuale DATE;
    DECLARE installazione_generatore DATE;

    # 1: Controlliamo la validità dei kWh
    IF NEW.kWh < 0 THEN
        SIGNAL SQLSTATE '45006'
        SET MESSAGE_TEXT = 'Il rendimento di un generatore deve essere maggiore o uguale a 0';
        
    ELSE
        # 2: Controlliamo che non sia una data futura
        SELECT CURDATE() INTO data_attuale;
        IF NEW.data > data_attuale THEN
            SIGNAL SQLSTATE '45007'
            SET MESSAGE_TEXT = 'La data del rendimento non puo superare la data attuale';
        ELSE
            # 3: Se i kWh sono validi controlliamo la coerenza con la data di installazione

            SELECT Generatore.data_installazione INTO installazione_generatore FROM Generatore 
                WHERE Generatore.id_generatore = NEW.generatore;

            IF NEW.data < installazione_generatore THEN
                SIGNAL SQLSTATE '45008'
                SET MESSAGE_TEXT = 'La data del rendimento precede la data di installazione del generatore associato';
            END IF;
        END IF;
    END IF;
END //
DELIMITER ;

# 1: La quantità di energia venduta in una fornitura deve essere maggiore di 0
# 2: Il costo di una fornitura deve essere maggiore o uguale a 0
# 3: La data della fornitura non puo superare la data attuale
# 4: Il totale di energia venduta in una giornata, nelle forniture effettuate da un produttore, non puo superare la somma dei rendimenti di quella giornata, dei generatori di quel produttore
# I controlli sono stati fatti in ordine di complessita
DROP TRIGGER IF EXISTS validita_fornitura;
DELIMITER //
CREATE TRIGGER validita_fornitura
BEFORE INSERT ON Fornitura
FOR EACH ROW
BEGIN
    DECLARE data_attuale DATE;
    DECLARE fornitura_giornaliera DECIMAL(10,3) DEFAULT 0.000;
    DECLARE rendimento_giornaliero DECIMAL(10,3) DEFAULT 0.000;

    # 1: Controlliamo i kWh
    IF NEW.kWh <= 0 THEN
        SIGNAL SQLSTATE '45009'
        SET MESSAGE_TEXT = 'La quantità di energia venduta in una fornitura deve essere maggiore di 0';
    ELSE
        # 2: Se sono corretti controlliamo il prezzo
        IF NEW.prezzo < 0 THEN
            SIGNAL SQLSTATE '45010'
            SET MESSAGE_TEXT = 'Il costo di una fornitura deve essere maggiore o uguale a 0';
        ELSE
            # 3: Se è corretta controlliamo che non sia una data futura
            SELECT CURDATE() INTO data_attuale;
            IF NEW.data > data_attuale THEN
                SIGNAL SQLSTATE '45011'
                SET MESSAGE_TEXT = 'La data della fornitura non puo superare la data attuale';
            ELSE
                # 4: Se tutto il resto è corretto eseguiamo il controllo più complesso
                SELECT SUM(Fornitura.kWh) INTO fornitura_giornaliera FROM Fornitura 
                    WHERE Fornitura.data = NEW.data AND Fornitura.distributore = NEW.distributore AND Fornitura.produttore = NEW.produttore;

                SELECT SUM(Rendimento.kWh) INTO rendimento_giornaliero FROM Rendimento
                    JOIN Generatore ON Generatore.id_generatore = Rendimento.generatore
                    WHERE Generatore.produttore = NEW.produttore AND Rendimento.data = NEW.data;

                IF (fornitura_giornaliera + NEW.kWh) > rendimento_giornaliero THEN
                    SIGNAL SQLSTATE '45012'
                    SET MESSAGE_TEXT = 'La fornitura supererebbe il rendimento del produttore';
                END IF;
            END IF;
        END IF;
    END IF;
END //
DELIMITER ;

# I controlli vengono effettuati nella procedura di inserimento della bolletta
# Qua ci limitiamo a controllare se una certa variabile di sessione è impostata o meno
DROP TRIGGER IF EXISTS inserimento_bolletta;
DELIMITER //
CREATE TRIGGER inserimento_bolletta
BEFORE INSERT ON Bolletta
FOR EACH ROW
BEGIN
    IF @bolletta_da_procedura IS NULL OR @bolletta_da_procedura = 0 THEN
        SIGNAL SQLSTATE '45013'
        SET MESSAGE_TEXT = 'Inserimenti manuali in Bolletta non sono validi, utilizzare la procedura apposita  Inserisci_bolletta';
    END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS modifica_bolletta;
DELIMITER //
CREATE TRIGGER modifica_bolletta
BEFORE UPDATE ON Bolletta
FOR EACH ROW
BEGIN
    IF @bolletta_da_procedura IS NULL OR @bolletta_da_procedura = 0 THEN
        SIGNAL SQLSTATE '45014'
        SET MESSAGE_TEXT = 'Modifiche manuali in Bolletta non sono validi, solo il pagamento e consentito tramite la procedura Paga_bolletta';
    END IF;
END //
DELIMITER ;



/*-------*\
   VISTE
\*-------*/

# Rendimento giornaliero di ogni produttore
DROP VIEW IF EXISTS rendimento_produttore;
CREATE VIEW rendimento_produttore(produttore, data, rendimento)
AS SELECT Generatore.produttore, Rendimento.data, SUM(Rendimento.kWh) AS rendimento
    FROM Generatore JOIN Rendimento ON Generatore.id_generatore = Rendimento.generatore 
    GROUP BY produttore, data;

# Rendimento giornaliero di Eni Plenitude (da produttore)
SELECT data, rendimento FROM rendimento_produttore WHERE produttore IN (SELECT p_iva FROM Produttore WHERE nome = 'Eni Plenitude');


# Quantità venduta e guadagno giornaliero di ogni produttore
DROP VIEW IF EXISTS vendita_guadagno_produttore;
CREATE VIEW vendita_guadagno_produttore(produttore, data, vendita, guadagno)
AS SELECT Produttore.p_iva, Fornitura.data, SUM(kWh), SUM(prezzo)
    FROM Produttore JOIN Fornitura ON Produttore.p_iva = Fornitura.produttore 
    GROUP BY p_iva, data;

# Esempio, quantità venduta e guadagno di VoltaEnergia
SELECT data, vendita, guadagno FROM vendita_guadagno_produttore WHERE produttore IN (SELECT p_iva FROM Produttore WHERE nome = 'VoltaEnergia');


# Quantità venduta e guadagno giornaliero di ogni distributore
DROP VIEW IF EXISTS vendita_guadagno_distributore;
CREATE VIEW vendita_guadagno_distributore(distributore, data, vendita, guadagno)
AS SELECT Distributore.p_iva, Consumo.data, SUM(Consumo.kWh), SUM(Consumo.kWh * Contratto.tariffa)
    FROM Distributore JOIN Contratto ON Distributore.p_iva = Contratto.distributore
    JOIN Immobile ON (Contratto.id_comune = Immobile.id_comune AND Contratto.id_unita_immobiliare = Immobile.id_unita_immobiliare)
    JOIN Consumo ON (Immobile.id_comune = Consumo.id_comune AND Immobile.id_unita_immobiliare = Consumo.id_unita_immobiliare)
    GROUP BY Distributore.p_iva, Consumo.data;

# Esempio, quantità venduta e guadagno di Eni Plenitude (da distributore)
SELECT data, vendita, guadagno FROM vendita_guadagno_distributore WHERE distributore IN (SELECT p_iva FROM Distributore WHERE nome = 'Eni Plenitude');


# Quantità invenduta giornaliera di ogni produttore
DROP VIEW IF EXISTS invenduto_produttore;
CREATE VIEW invenduto_produttore(produttore, data, invenduto)
AS SELECT vendita_guadagno_produttore.produttore, vendita_guadagno_produttore.data, (rendimento_produttore.rendimento - vendita_guadagno_produttore.vendita)
    FROM vendita_guadagno_produttore JOIN rendimento_produttore 
         ON (
            vendita_guadagno_produttore.produttore = rendimento_produttore.produttore
            AND
            vendita_guadagno_produttore.data = rendimento_produttore.data
        );

# Esempio, quantità invendute di EcoEnergia
SELECT data, invenduto FROM invenduto_produttore WHERE produttore IN (SELECT p_iva FROM Produttore WHERE nome = 'EcoEnergia');


/*----------*\
   FUNZIONI
\*----------*/

# Calcola il costo di una bolletta
DROP FUNCTION IF EXISTS costo_bolletta;
DELIMITER //
CREATE FUNCTION costo_bolletta(contratto INT, data_inizio DATE, data_fine DATE) 
RETURNS DECIMAL(6,2)
DETERMINISTIC
BEGIN
    DECLARE costo DECIMAL(6,2) DEFAULT 0.00;

    # Calcola il costo della bolletta considerando ogni consumo per l'immobile coperto dal contratto a cui fa riferimento la bolletta
    SELECT SUM(kWh*Contratto.tariffa) INTO costo FROM Contratto 
        JOIN Immobile ON (Contratto.id_comune = Immobile.id_comune AND Contratto.id_unita_immobiliare = Immobile.id_unita_immobiliare)
        JOIN Consumo ON (Immobile.id_comune = Consumo.id_comune AND Immobile.id_unita_immobiliare = Consumo.id_unita_immobiliare)
        WHERE Contratto.id_contratto = contratto AND (Consumo.data BETWEEN data_inizio AND data_fine); 

    RETURN costo;
END //
DELIMITER ;



/*-----------*\
   PROCEDURE
\*-----------*/

# 1: La data che indica la fine del periodo di riferimento di una bolletta deve essere antecedente a quella attuale
# 2: La data che indica l'inizio del periodo di riferimento della bolletta deve essere antecedente alla data che indica la fine del periodo di riferimento
# 3: La data di pagamento di una bolletta, se pagata, deve essere successiva alla data che indica la fine del periodo di riferimento
# 4: Il periodo di riferimento di una bolletta deve rientrare nel periodo di validità del contratto a cui fa riferimento
# 5: Non sono ammesse bollette che riferiscono allo stesso contratto, che coprono lo stesso periodo, o parte di esso, di un altra bolletta già esistente
# 6: Il costo di una bolletta deve essere la somma dei consumi giornalieri del periodo di riferimento moltiplicata per la tariffa del rispettivo contratto
# I controlli sono stati fatti in ordine di complessita
DROP PROCEDURE IF EXISTS Inserisci_bolletta;
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS Inserisci_bolletta(IN id_bolletta INT, IN contratto INT, IN data_pagamento DATE, IN data_scadenza DATE, IN data_inizio DATE, IN data_fine DATE)
COMMENT 'Inserisce una nuova bolletta, se rispetta i vincoli di validità'
BEGIN
    DECLARE data_attuale DATE;
    DECLARE inizio_contratto DATE;
    DECLARE fine_contratto DATE;
    DECLARE sovrapposizioni INT;
    DECLARE costo DECIMAL(6,2);

    # 1: Controlliamo che se la data di fine supera la data attuale
    SELECT CURDATE() INTO data_attuale;
    IF data_fine >= data_attuale THEN
        SIGNAL SQLSTATE '45015'
        SET MESSAGE_TEXT = 'La data di fine periodo della bolletta non deve superare la data attuale';
    ELSE 
        # 2: Controlliamo la coerenza delle date di inizio e fine
        IF data_inizio > data_fine THEN
            SIGNAL SQLSTATE '45016'
            SET MESSAGE_TEXT = 'La data di inizio periodo deve precedere la data di fine periodo';
        ELSE
            # 3: Controlliamo la coerenza della data di pagamento, se pagata
            IF data_pagamento IS NOT NULL AND (data_pagamento <= data_fine) THEN
                SIGNAL SQLSTATE '45017'
                SET MESSAGE_TEXT = 'La data di pagamento della bolletta non puo superare la data di fine bolletta';
            ELSE
                # 4: Controlliamo che la bolletta rientri nel periodo di riferimento del contratto
                SELECT Contratto.data_stipulazione INTO inizio_contratto FROM Contratto WHERE Contratto.id_contratto = contratto;
                SELECT Contratto.data_scadenza INTO fine_contratto FROM Contratto WHERE Contratto.id_contratto = contratto;
                IF data_inizio < inizio_contratto OR data_fine > fine_contratto THEN
                    SIGNAL SQLSTATE '45018'
                    SET MESSAGE_TEXT = 'Il periodo della bolletta deve rientrare nel periodo di copertura del contratto';
                ELSE
                    # 5: Controlliamo che non ci siano sovrapposizioni
                    SELECT COUNT(*) INTO sovrapposizioni FROM Bolletta WHERE Bolletta.contratto = Contratto AND
                    (
                        (data_inizio BETWEEN Bolletta.data_inizio AND Bolletta.data_fine) OR
                        (data_fine BETWEEN Bolletta.data_inizio AND Bolletta.data_fine) OR
                        (Bolletta.data_inizio BETWEEN data_inizio AND data_fine) OR
                        (Bolletta.data_fine  BETWEEN data_inizio AND data_fine)
                    );
                    IF sovrapposizioni > 0 THEN
                        SIGNAL SQLSTATE '45019'
                        SET MESSAGE_TEXT = "La bolletta copre il periodo di riferimento di un'altra bolletta dello stesso contratto";
                    ELSE
                        # 6: Calcoliamo il costo della bolletta e poi la aggiungiamo
                        SET costo = costo_bolletta(contratto, data_inizio, data_fine);

                        # Procediamo all inserimento
                        SET @bolletta_da_procedura = 1;
                        INSERT INTO Bolletta VALUES(id_bolletta, contratto, costo, data_pagamento, data_scadenza, data_inizio, data_fine);
                        SET @bolletta_da_procedura = 0;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS Paga_bolletta;
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS Paga_bolletta(IN bolletta INT)
COMMENT 'Aggiorna la bolletta non pagata con una data di pagamento, se non era stata già pagata'
BEGIN

    DECLARE vecchia_data_pagamento DATE;
    DECLARE nuova_data_pagamento DATE;

    SELECT Bolletta.data_pagamento INTO vecchia_data_pagamento FROM Bolletta 
        WHERE Bolletta.id_bolletta = bolletta;
    SELECT CURDATE() INTO nuova_data_pagamento;
 
    # Controlliamo se la bolletta è già pagata
    IF vecchia_data_pagamento IS NULL THEN
        # La bolletta non è stata ancora pagata
        SET @bolletta_da_procedura = 1;
        UPDATE Bolletta SET Bolletta.data_pagamento = nuova_data_pagamento WHERE Bolletta.id_bolletta = Bolletta;
        SET @bolletta_da_procedura = 0;
    ELSE
        # Era stata pagata
        SIGNAL SQLSTATE '45020'
        SET MESSAGE_TEXT = 'La bolletta è stata già pagata';
    END IF;
END //
DELIMITER ;


/*----------------*\
   INTERROGAZIONI
\*----------------*/

# Pagamento di una bolletta
# Una bolletta non pagata riceve come data di pagamento la data odierna (es. id_bolletta 1)
SELECT * FROM Bolletta WHERE id_bolletta = 1;
CALL Paga_bolletta(1);
SELECT * FROM Bolletta WHERE id_bolletta = 1;

# Intestatari con bollette pagate in ritardo, con numero di contratto, indirizzo dell immobile coperto dal contratto e data di scadenza/pagamento della bolletta
SELECT CONCAT(Intestatario.nome, ' ', Intestatario.cognome) AS intestatario, CONCAT(Immobile.via, ' ', Immobile.civico) AS 'indirizzo immobile', Contratto.id_contratto, Bolletta.id_bolletta, Bolletta.data_scadenza, Bolletta.data_pagamento FROM
    Intestatario JOIN Responsabile ON Intestatario.CF = Responsabile.CF
    JOIN Contratto ON Responsabile.id_contratto = Contratto.id_contratto
    JOIN Immobile ON (Contratto.id_comune = Immobile.id_comune AND Contratto.id_unita_immobiliare = Immobile.id_unita_immobiliare)
    JOIN Bolletta ON Contratto.id_contratto = Bolletta.contratto
    WHERE Bolletta.data_pagamento > Bolletta.data_scadenza
    ORDER BY Contratto.id_contratto;

# Elenco dei contratti attivi con i rispettivi intestatari
SELECT 
    Distributore.nome as distributore, 
    Contratto.tariffa, 
    Contratto.limite_kW AS 'limite kW', 
    Contratto.data_stipulazione AS 'data stipulazione', 
    Contratto.data_scadenza AS 'data scadenza', 
    GROUP_CONCAT(CONCAT(Intestatario.nome, ' ', Intestatario.cognome)) as intestatari
    FROM Distributore JOIN Contratto ON Distributore.p_iva = Contratto.distributore
    LEFT JOIN Responsabile ON Contratto.id_contratto = Responsabile.id_contratto
    JOIN Intestatario ON Responsabile.CF = Intestatario.CF
    WHERE Contratto.data_scadenza > CURDATE()
    GROUP BY Contratto.id_contratto
    ORDER BY Distributore.nome;

# Elenco dei contratti cointestati (con almeno 2 intestatari)
SELECT 
    Distributore.nome as distributore, 
    Contratto.tariffa, 
    Contratto.limite_kW AS 'limite kW', 
    Contratto.data_stipulazione AS 'data stipulazione', 
    Contratto.data_scadenza AS 'data scadenza', 
    GROUP_CONCAT(CONCAT(Intestatario.nome, ' ', Intestatario.cognome)) as intestatari
    FROM Distributore JOIN Contratto ON Distributore.p_iva = Contratto.distributore
    JOIN Responsabile ON Contratto.id_contratto = Responsabile.id_contratto
    JOIN Intestatario ON Responsabile.CF = Intestatario.CF
    GROUP BY Contratto.id_contratto
    HAVING COUNT(Intestatario.CF) > 1;

# Elenco degli immobili che hanno più piani/unità
SELECT Immobile.via, Immobile.civico, Immobile.CAP, GROUP_CONCAT(DISTINCT Immobile.tipo_abitazione) AS 'tipo immobile' FROM Immobile
    WHERE id_unita_immobiliare LIKE '%-%-%' GROUP BY Immobile.via, Immobile.civico, Immobile.CAP;

# Tutte le forniture associate al distributore Enel Energia
SELECT data, SUM(Fornitura.kWh) AS fornitura, GROUP_CONCAT(Produttore.nome) as Produttori FROM Fornitura
    JOIN Produttore on Fornitura.produttore = Produttore.p_iva
    WHERE Fornitura.distributore IN (SELECT p_iva FROM Distributore WHERE nome = 'Enel Energia')
    GROUP BY Fornitura.data;

# La produzione giornaliera, a confronto, dei generatori di tipo rinnovabile (eolico e fotovoltaico) e non rinnovabile (gas e carbone)
SELECT g1.data, g1.rendimento AS 'Rendimento rinnovabile', g2.rendimento AS 'Rendimento non rinnovabile' FROM
(
    SELECT Rendimento.data, SUM(Rendimento.kWh) as rendimento FROM 
            Generatore JOIN Rendimento ON Generatore.id_generatore = Rendimento.generatore
            WHERE (Generatore.tipo_generatore = 'eolico' OR Generatore.tipo_generatore = 'fotovoltaico')
            GROUP BY Rendimento.data
) g1,
(
    SELECT Rendimento.data, SUM(Rendimento.kWh) as rendimento FROM 
            Generatore JOIN Rendimento ON Generatore.id_generatore = Rendimento.generatore
            WHERE (Generatore.tipo_generatore = 'gas' OR Generatore.tipo_generatore = 'carbone')
            GROUP BY Rendimento.data    
) g2
WHERE g1.data = g2.data;

# I tre immobili che hanno consumato di più durante il fine settimana 23.08.2024 - 25.08.2024
SELECT CONCAT(Immobile.via, ' ', Immobile.civico, ' ', Immobile.CAP) as Indirizzo, SUM(Consumo.kWh) as Consumo FROM 
    Immobile JOIN Consumo ON (Immobile.id_comune = Consumo.id_comune AND Immobile.id_unita_immobiliare = Consumo.id_unita_immobiliare)
    WHERE Consumo.data BETWEEN '2024-08-23' AND '2024-08-25'
    GROUP BY Consumo.id_comune, Consumo.id_unita_immobiliare
    ORDER BY Consumo DESC
    LIMIT 3;