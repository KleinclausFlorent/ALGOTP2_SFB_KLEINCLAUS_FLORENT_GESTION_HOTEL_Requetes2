--Classement des client par nombre d occupations
SELECT TJ_CHB_PLN_CLI.CLI_ID,count(CHB_PLN_CLI_OCCUPE) as Occupations,CLI_NOM,CLI_PRENOM 
 FROM TJ_CHB_PLN_CLI,T_CLIENT 
WHERE TJ_CHB_PLN_CLI.CLI_ID=T_CLIENT.CLI_ID
 group by TJ_CHB_PLN_CLI.CLI_ID 
order by Occupations DESC;
--Classement des clients par montant dépensé dans l hôtel
SELECT T_CLIENT.CLI_ID as "ID",CLI_NOM as "Nom",CLI_PRENOM as "Prenom",
ROUND(sum( ( ( LIF_MONTANT*LIF_QTE-ifnull(LIF_REMISE_MONTANT,0))*(1-ifnull(LIF_REMISE_POURCENT,0)/100 ) )* (1+LIF_TAUX_TVA/100 ) ),2) as "total montant"
FROM T_CLIENT,T_FACTURE,T_LIGNE_FACTURE
WHERE "ID"=T_FACTURE.CLI_ID AND T_FACTURE.FAC_ID=T_LIGNE_FACTURE.FAC_ID AND LIF_REMISE_POURCENT is not null
Group by "ID"
ORDER BY "total montant" DESC;
--Classement des occupations par mois
SELECT strftime("%m",PLN_JOUR) as "mois",count(CHB_PLN_CLI_OCCUPE) as "nombre occupations"
FROM TJ_CHB_PLN_CLI
group by "mois"
order by "nombre occupations" DESC;
--Classement des occupations par trimestre
SELECT cast(strftime("%m",PLN_JOUR)as INTEGER) %4 +1 as "mois",count(CHB_PLN_CLI_OCCUPE) as "nombre occupations"
FROM TJ_CHB_PLN_CLI
group by "mois"
order by "nombre occupations" DESC;
--MONTANT TTC de chaque ligne de facture (avec remises)
SELECT LIF_ID,ROUND(sum( ( ( LIF_MONTANT*LIF_QTE-ifnull(LIF_REMISE_MONTANT,0))*(1-ifnull(LIF_REMISE_POURCENT,0)/100 ) )* (1+LIF_TAUX_TVA/100 ) ),2) as "total montant"
FROM T_LIGNE_FACTURE
group by LIF_ID
ORDER BY "total montant" DESC;
--CLASSEMENT du montant total TTC (avec remises) des factures
SELECT FAC_ID,ROUND(sum( ( ( LIF_MONTANT*LIF_QTE-ifnull(LIF_REMISE_MONTANT,0))*(1-ifnull(LIF_REMISE_POURCENT,0)/100 ) )* (1+LIF_TAUX_TVA/100 ) ),2) as "total montant"
FROM T_LIGNE_FACTURE
group by FAC_ID
ORDER BY "total montant" DESC;
--Tarif moyen des chambres par années croissantes
SELECT ROUND(AVG(TRF_CHB_PRIX*(1+TRF_TAUX_TAXES/100)),2) as "Tarif moyen",strftime("%Y",TJ_CHB_TRF.TRF_DATE_DEBUT) as "année"
FROM TJ_CHB_TRF,T_TARIF
WHERE T_TARIF.TRF_DATE_DEBUT=TJ_CHB_TRF.TRF_DATE_DEBUT
group by "année"
order by "année" ASC;
--Tarif moyen des chambres par étage et années croissantes
SELECT ROUND(AVG(TRF_CHB_PRIX*(1+TRF_TAUX_TAXES/100)),2) as "Tarif moyen",strftime("%Y",TJ_CHB_TRF.TRF_DATE_DEBUT) as "année",CHB_ETAGE as "étage"
FROM TJ_CHB_TRF,T_TARIF,T_CHAMBRE
WHERE T_TARIF.TRF_DATE_DEBUT=TJ_CHB_TRF.TRF_DATE_DEBUT AND
T_CHAMBRE.CHB_ID=TJ_CHB_TRF.CHB_ID
group by "étage","année"
order by "année" ASC;
--Chambre la plus cher et en quelle année
SELECT ROUND(TRF_CHB_PRIX*(1+TRF_TAUX_TAXES/100),2) as "montant",strftime("%Y",TJ_CHB_TRF.TRF_DATE_DEBUT) as "année",T_CHAMBRE.CHB_ID
FROM TJ_CHB_TRF,T_TARIF,T_CHAMBRE
WHERE T_TARIF.TRF_DATE_DEBUT=TJ_CHB_TRF.TRF_DATE_DEBUT AND
T_CHAMBRE.CHB_ID=TJ_CHB_TRF.CHB_ID AND "montant"=(SELECT ROUND(MAX(TRF_CHB_PRIX*(1+TRF_TAUX_TAXES/100)),2) FROM TJ_CHB_TRF);
--Chambre réservées mais pas occupées
Select CHB_ID,count(CHB_PLN_CLI_OCCUPE),count(CHB_PLN_CLI_RESERVE) 
FROM TJ_CHB_PLN_CLI 
WHERE CHB_PLN_CLI_OCCUPE=0 AND CHB_PLN_CLI_RESERVE=1
group by CHB_ID;
--Taux de réservation par chambre
Select CHB_ID,
ROUND(COUNT(NULLIF(CHB_PLN_CLI_RESERVE,0))*1.0/COUNT(CHB_PLN_CLI_OCCUPE),2) as "TAUX de réservation"
FROM TJ_CHB_PLN_CLI
group by CHB_ID
ORDER by "TAUX de réservation" DESC;
--Factures réglées avant leur édition
SELECT FAC_ID,FAC_DATE,FAC_PMT_DATE
FROM T_FACTURE
WHERE julianday(FAC_DATE)>julianday(FAC_PMT_DATE);
--Par qui ont été payées ces factures réglées en avance 
SELECT FAC_ID,FAC_DATE,FAC_PMT_DATE,T_FACTURE.CLI_ID,CLI_NOM,CLI_PRENOM
FROM T_FACTURE,T_CLIENT
WHERE T_FACTURE.CLI_ID=T_CLIENT.CLI_ID
 AND julianday(FAC_DATE)>julianday(FAC_PMT_DATE)
group by T_FACTURE.CLI_ID;
--Classement des modes de paiement( par mode et le montant total généré)
SELECT ROUND(sum( ( ( LIF_MONTANT*LIF_QTE-ifnull(LIF_REMISE_MONTANT,0))*(1-ifnull(LIF_REMISE_POURCENT,0)/100 ) )* (1+LIF_TAUX_TVA/100 ) ),2) as "total montant",PMT_CODE
FROM T_LIGNE_FACTURE,T_FACTURE
WHERE T_LIGNE_FACTURE.FAC_ID=T_FACTURE.FAC_ID
Group by PMT_CODE
ORDER BY "total montant" DESC;
--VOUS vous créez en tant que client de l'hôtel
Insert into T_CLIENT (CLI_ID,CLI_NOM,CLI_PRENOM,TIT_CODE)
values ((select MAX(CLI_ID)+1 FROM T_CLIENT),"KLEINCLAUS","FLORENT","M.");
--Ne pas oubliez vos moyens de communications
--mail
Insert into T_EMAIL (EML_ID,EML_ADRESSE,EML_LOCALISATION,CLI_ID)
values ((select MAX(EML_ID)+1 FROM T_EMAIL),"kleinclaus.florent@gmail.com","Domicile",(select CLI_ID from T_CLIENT WHERE CLI_NOM="KLEINCLAUS"));
--Téléphone
Insert into T_TELEPHONE (TEL_ID,TEL_NUMERO,TEL_LOCALISATION,CLI_ID,TYP_CODE)
values ((select MAX(TEL_ID)+1 FROM T_TELEPHONE),"06-74-35-27-00","Domicile",(select CLI_ID from T_CLIENT WHERE CLI_NOM="KLEINCLAUS"),"TEL");
--Adresse
Insert into T_ADRESSE (ADR_ID,ADR_LIGNE1,ADR_LIGNE2,ADR_LIGNE3,ADR_LIGNE4,ADR_CP,ADR_VILLE,CLI_ID)
values ((select MAX(ADR_ID)+1 FROM T_ADRESSE),"1, rue de la Chapelle","","","","67100","STRASBOURG",(select CLI_ID from T_CLIENT WHERE CLI_NOM="KLEINCLAUS"));
--Vous créez une nouvelle chambre à la date du jour
--Vous serez 3 occupants et souhaitez le maximum de confort pour cette chambre dont le prix est 30% supérieur à la chambre la plus cher
	--Création de la chambre avec le maximum de confort
	Insert into T_CHAMBRE (CHB_ID,CHB_NUMERO,CHB_ETAGE,CHB_BAIN,CHB_DOUCHE,CHB_WC,CHB_COUCHAGE,CHB_POSTE_TEL)
	values ((select MAX(CHB_ID)+1 FROM T_CHAMBRE),(SELECT MAX(CHB_NUMERO)+1 FROM T_CHAMBRE),"RDC",1,1,1,3,(SELECT MAX(CHB_POSTE_TEL)+1 FROM T_CHAMBRE));
	--Création de l occupation dans le planning
	Insert into TJ_CHB_PLN_CLI (CHB_PLN_CLI_NB_PERS,CHB_PLN_CLI_RESERVE,CHB_PLN_CLI_OCCUPE,CHB_ID,PLN_JOUR,CLI_ID)
	values (3,0,1,(SELECT MAX(CHB_ID) FROM T_CHAMBRE),STRFTIME("%Y-%m-%d","now"),(select CLI_ID from T_CLIENT WHERE CLI_NOM="KLEINCLAUS"));
	--Création du tarif
	Insert into TJ_CHB_TRF (TRF_CHB_PRIX,CHB_ID,TRF_DATE_DEBUT)
	values ( (SELECT ROUND((MAX(TRF_CHB_PRIX)*1.3),2) FROM TJ_CHB_TRF),(SELECT MAX(CHB_ID) FROM T_CHAMBRE),STRFTIME("%Y-%m-%d","now"));
--le réglement de votre facture sera effectué en CB
	--Création de la facture dans T_FACTURE
	Insert into T_FACTURE(FAC_ID,FAC_DATE,CLI_ID,FAC_PMT_DATE,PMT_CODE)
	values ((SELECT MAX(FAC_ID)+1 FROM T_FACTURE),STRFTIME("%Y-%m-%d","now"),(select CLI_ID from T_CLIENT WHERE CLI_NOM="KLEINCLAUS"),STRFTIME("%Y-%m-%d","now"),"CB");
	--Création de la ligne facture
	Insert into T_LIGNE_FACTURE(LIF_ID,LIF_QTE,LIF_REMISE_POURCENT,LIF_REMISE_MONTANT,LIF_MONTANT,LIF_TAUX_TVA,FAC_ID)
	values ((SELECT MAX(LIF_ID)+1 FROM T_LIGNE_FACTURE),1,null,null,(select TRF_CHB_PRIX FROM TJ_CHB_TRF WHERE CHB_ID=(select max(CHB_ID) from T_CHAMBRE)),(SELECT TRF_TAUX_TAXES FROM T_TARIF WHERE TRF_DATE_DEBUT=(SELECT max(TRF_DATE_DEBUT) FROM T_TARIF)),(SELECT MAX(FAC_ID) FROM T_FACTURE));
--Une 2nde facture a été éditée car le tarif a changé : rabais de 10%
	-- modification de la ligne facture pour ajouter la remise de 10%
	update T_LIGNE_FACTURE
	set LIF_REMISE_POURCENT = 10
	where LIF_ID=(SELECT max(LIF_ID) FROM T_LIGNE_FACTURE);