DROP TABLE IF EXISTS Reservations;
DROP TABLE IF EXISTS Indisponibilite;
DROP TABLE IF EXISTS Employes;
DROP TABLE IF EXISTS Reservations;
DROP TABLE IF EXISTS Exemplaires ;
DROP TABLE IF EXISTS Materiels;
DROP TABLE IF EXISTS SousCategories;
DROP TABLE IF EXISTS Categories;

CREATE TABLE Materiels (
	id_MAT INTEGER NOT NULL,
	libelle_Mat TEXT  ,
	id_Cat INTEGER , 
	CONSTRAINT pk_mat_id_mat PRIMARY KEY (id_Mat),
	CONSTRAINT ck_mat_id_mat  CHECK (id_Mat > 0 ) ,
	CONSTRAINT fk_mat_id_cat FOREIGN KEY (id_Cat ) REFERENCES Categories ( id_Cat ),
	CONSTRAINT ck_mat_id_cat  CHECK (id_Cat > 0 ) 
);

CREATE TABLE Categories (
	id_Cat INTEGER NOT NULL ,
	libelle_Cat TEXT NOT NULL, 
	nb_Emprunts_Max INTEGER , 
	CONSTRAINT pk_cat_id_cat PRIMARY KEY (id_Cat),
	CONSTRAINT ck_cat_id_cat  CHECK (id_Cat > 0 ),
	CONSTRAINT ck_cat_nb_emprunts_max  CHECK (nb_Emprunts_Max >= 0 ) 
);

CREATE TABLE SousCategories (
	id_Sous_Cat INTEGER NOT NULL ,
	libelle_SousCat TEXT NOT NULL,
	id_Cat INTEGER NOT NULL,
	CONSTRAINT pk_SousCat_id_cat PRIMARY KEY (id_Sous_Cat),
	CONSTRAINT fk_SousCat_id_cat FOREIGN KEY (id_Cat) REFERENCES Categories (id_Cat),
	CONSTRAINT ck_SousCat_id_Souscat  CHECK (id_Sous_Cat > 0 ),
	CONSTRAINT ck_SousCat_id_cat  CHECK (id_Cat > 0 )
);

CREATE TABLE Exemplaires (
	id_Ex INTEGER NOT NULL , 
	id_Mat INTEGER NOT NULL , 
	etat TEXT ,
	id_indisponibilite INTEGER , 
	CONSTRAINT pk_exe_id_exp_id_mat PRIMARY KEY (id_Ex ,id_Mat ),
	CONSTRAINT fk_exe_id_mat FOREIGN KEY (id_Mat ) REFERENCES Materiels ( id_Mat ),
	CONSTRAINT fk_exe_iid_indisponibilite FOREIGN KEY (id_indisponibilite ) REFERENCES Indisponibilite ( id_indisponibilite ),
	CONSTRAINT ck_exe_etat CHECK ( etat IN ('neuf' , 'bon' , 'moyen' , 'defectueux') ),
	CONSTRAINT ck_exe_id_ex  CHECK (id_Ex > 0 ) ,
	CONSTRAINT ck_exe_id_mat  CHECK (id_Mat > 0 ),
	CONSTRAINT ck_exe_id_indisponibilite CHECK (id_indisponibilite IS NULL OR id_indisponibilite > 0)
);

CREATE TABLE Indisponibilite (
	id_indisponibilite INTEGER,
	description_indisponibilite TEXT ,
	CONSTRAINT pk_ind_id_indisponibilite PRIMARY KEY (id_indisponibilite)
	--CONSTRAINT fk_ind_idInd FOREIGN KEY (id_indisponibilite) REFERENCES Exemplaire (id_indisponibilite),
	CONSTRAINT ck_ind_id_indisponibilite CHECK (id_indisponibilite > 0),
	CONSTRAINT ck_ind_description_indisponibilite CHECK (description_indisponibilite IN ('panne', 'maintenance', 'perdu'))
);

CREATE TABLE Reservations (
	id_reservation INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	id_exemplaire INTEGER NOT NULL,
	id_materiel INTEGER NOT NULL,
	id_employe INTEGER NOT NULL,
	date_debut DATE NOT NULL,
	date_fin DATE NOT NULL,
	date_emprunt DATE,
	date_retour DATE,
	CONSTRAINT fk_res_idExe FOREIGN KEY (id_exemplaire, id_materiel) REFERENCES Exemplaires (id_Ex, id_Mat),
	CONSTRAINT fk_res_idEmp FOREIGN KEY (id_employe) REFERENCES Employes (id_employe),
	CONSTRAINT ck_res_idRes CHECK (id_reservation > 0),
	CONSTRAINT ck_res_idExe CHECK (id_exemplaire > 0),
	CONSTRAINT ck_res_idEmp CHECK (id_employe > 0),
	CONSTRAINT ck_res_date_emprunt_debut CHECK (date_emprunt >= date_debut),
	CONSTRAINT ck_res_date_emprunt_fin CHECK (date_emprunt <= date_fin),
	CONSTRAINT ck_res_date_retour_emprunt CHECK (date_retour >= date_emprunt)
);


CREATE TABLE Employes (
	id_employe INTEGER NOT NULL,
	nom_employe TEXT NOT NULL,
	mail TEXT NOT NULL,
	tel TEXT NOT NULL,
	CONSTRAINT pk_emp_idEmp PRIMARY KEY (id_employe),
	CONSTRAINT ck_emp_idEmp CHECK (id_employe > 0)
);


INSERT INTO Categories 
SELECT DISTINCT id_categorie, libelle_categorie, nb_emprunt_max
FROM Resa
WHERE id_categorie >0 AND id_categorie IS NOT NULL AND nb_emprunt_max >= 0;
	
INSERT INTO SousCategories
VALUES (17, 'Nettoyage', 1), 
	(18, 'Outils', 1),
	(19, 'Jardinage', 1),
	(20, 'Réparation', 1),
	(12, 'Dessin Animé', 5),
	(10, '-12 ans', 4),
	(11, '-18 ans', 4);

INSERT INTO Materiels
SELECT DISTINCT id_materiel, libelle_materiel, id_categorie
FROM Resa
WHERE id_materiel > 0 AND id_categorie > 0;
	
INSERT INTO Exemplaires (id_Ex, id_Mat, etat, id_indisponibilite)
SELECT DISTINCT	id_exemplaire, id_materiel, etat, id_indisponibilite
FROM Resa
WHERE id_exemplaire > 0
  AND (etat IN ('neuf', 'bon', 'moyen', 'defectueux') OR etat IS NULL)
  AND id_materiel > 0;
  
INSERT INTO Indisponibilite
SELECT DISTINCT id_indisponibilite, description_indisponibilite
FROM Resa
WHERE id_indisponibilite IS NOT NULL 
  AND description_indisponibilite IN ('panne', 'maintenance', 'perdu');

INSERT INTO Employes
SELECT DISTINCT id_employe, nom_employe, mail, tel
FROM Resa
WHERE id_employe IS NOT NULL AND nom_employe IS NOT NULL AND mail IS NOT NULL AND tel IS NOT NULL;

	
INSERT INTO Reservations (
	id_exemplaire,
	id_materiel,
	id_employe,
	date_debut,
	date_fin,
	date_emprunt,
	date_retour
)
SELECT DISTINCT
	id_exemplaire,
	id_materiel,
	id_employe,
	date_debut,
	date_fin,
	date_emprunt,
	date_retour
FROM Resa
WHERE id_exemplaire > 0
  AND id_materiel > 0
  AND id_employe > 0
  AND date_debut IS NOT NULL
  AND date_fin IS NOT NULL;

DROP VIEW IF EXISTS V_NbEmpruntsEmploye;
DROP VIEW IF EXISTS V_NbEmpruntsMateriel;

-- vue 1
CREATE VIEW V_NbEmpruntsEmploye AS
SELECT 
    Employes.id_employe,
    Employes.nom_employe,
    COUNT(*) 
FROM Reservations
JOIN Employes ON Reservations.id_employe = Employes.id_employe
WHERE '2024-02-14' BETWEEN Reservations.date_emprunt AND Reservations.date_retour -- à remplacer avec CURRENT_DATE pour la date actuelle
GROUP BY Employes.id_employe, Employes.nom_employe;

-- vue 2
CREATE VIEW V_NbEmpruntsMateriel AS
SELECT 
    Materiels.id_Mat,
    Materiels.libelle_Mat,
    COUNT(*) 
FROM Reservations
JOIN Materiels ON Reservations.id_materiel = Materiels.id_Mat
WHERE '2024-02-14' BETWEEN Reservations.date_emprunt AND Reservations.date_retour -- à remplacer avec CURRENT_DATE pour la date actuelle
GROUP BY Materiels.id_Mat, Materiels.libelle_Mat;



--- pour le test

