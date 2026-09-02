--- pour le test

-- 1. Quelles sont les catégories de matériel réservés par l’employé ’Martin’ ?
SELECT DISTINCT Categories.libelle_Cat
FROM Reservations
JOIN Materiels ON Reservations.id_materiel = Materiels.id_Mat
JOIN Categories ON Materiels.id_Cat = Categories.id_Cat
JOIN Employes ON Reservations.id_employe = Employes.id_employe
WHERE Employes.nom_employe = 'Martin';

-- 2. Quels employés ont réservé l’appareil photo compact (id materiel=37) et l’appareil photo reflex (id materiel=38) ?
SELECT Employes.nom_employe
FROM Employes
WHERE Employes.id_employe IN (
    SELECT Reservations.id_employe
    FROM Reservations
    WHERE Reservations.id_materiel = 37
)
AND Employes.id_employe IN (
    SELECT Reservations.id_employe
    FROM Reservations
    WHERE Reservations.id_materiel = 38
);

-- 3. Combien d’employés ont réservé l’appareil photo compact (id materiel=37) OU l’appareil photo reflex (id materiel=38) ?
SELECT COUNT(DISTINCT Reservations.id_employe) AS nb_employes
FROM Reservations
WHERE Reservations.id_materiel = 37 OR Reservations.id_materiel = 38;

-- 4. Quels employés n’ont rien réservé ?
SELECT Employes.nom_employe
FROM Employes
LEFT JOIN Reservations ON Employes.id_employe = Reservations.id_employe
WHERE Reservations.id_reservation IS NULL;

-- 5. Quels employés ont réservé au moins 1 matériel de chaque catégorie (votre résultat doit comprendre 197 employés) ?
SELECT id_employe, nom_employe
FROM Employes JOIN Reservations USING(id_employe)
JOIN Materiels ON (Reservations.id_materiel = Materiels.id_MAT)
GROUP BY Employes.nom_employe
HAVING COUNT(DISTINCT Materiels.id_Cat) IN
( 
 	SELECT COUNT(Categories.id_Cat)
 	FROM Categories
);

-- 6. Quel est le nombre d’exemplaires de chaque matériel (donner l’id et libellé) ?
SELECT Materiels.id_Mat, Materiels.libelle_Mat, COUNT(Exemplaires.id_Ex) AS nb_exemplaires
FROM Materiels
LEFT JOIN Exemplaires ON Materiels.id_Mat = Exemplaires.id_Mat
GROUP BY Materiels.id_Mat, Materiels.libelle_Mat;

-- 7. Quels employés ont fait au moins 60 réservations ?
SELECT Employes.nom_employe, COUNT(Reservations.id_reservation) AS nb_reservations
FROM Reservations
JOIN Employes ON Reservations.id_employe = Employes.id_employe
GROUP BY Employes.id_employe, Employes.nom_employe
HAVING COUNT(Reservations.id_reservation) >= 60;

-- 8. Quels employés ont emprunté au moins 2 fois la perceuse (id materiel=20) ?
WITH IDEMP AS (
SELECT  R.id_employe --,R.id_materiel
FROM Reservations R 
WHERE R.id_materiel = 20  AND date_emprunt IS NOT  NULL -- PEUT ETRE RESERVER MAIS PEUT ETRE NE PAS EMPRUNTER
GROUP BY id_employe
HAVING COUNT(*) >=2)
SELECT E.nom_employe
FROM Employes E JOIN IDEMP I ON (E.id_employe = I.id_employe);

-- 9. Quel matériels ont été réservés le plus longtemps (sur 1 seule réservation) ?
WITH Durees AS (
    SELECT 
        M.id_Mat,
        M.libelle_Mat,--R.id_employe,--R.date_debut, date_fin,--R.date_retour,R.date_emprunt,
	   (julianday(R.date_fin) - julianday(R.date_debut)) AS duree_totale
    FROM Reservations R
    JOIN Materiels M ON R.id_materiel = M.id_Mat
    --WHERE R.date_emprunt IS NOT NULL AND R.date_retour IS NOT NULL
    GROUP BY M.id_Mat, M.libelle_Mat
)
SELECT *
FROM Durees
WHERE duree_totale = (SELECT MAX(duree_totale) FROM Durees);

-- 10. Quels sont les exemplaires (et le nom du matériel) qui ont été réservés le plus de fois ?
WITH compteReservations AS (
    SELECT id_exemplaire, libelle_Mat, COUNT(*) AS nb_reservations
    FROM Reservations JOIN Exemplaires ON Reservations.id_exemplaire = Exemplaires.id_Ex
    JOIN Materiels ON Exemplaires.id_Mat = Materiels.id_Mat
    GROUP BY Reservations.id_exemplaire, Materiels.libelle_Mat
),
maxReservations AS (
    SELECT MAX(nb_reservations) AS maxRes FROM CompteReservations
)
SELECT id_exemplaire, libelle_Mat, nb_reservations
FROM compteReservations
JOIN maxReservations ON compteReservations.nb_reservations = maxReservations.maxRes;


