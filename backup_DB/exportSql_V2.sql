--
-- PostgreSQL database dump
--

-- Dumped from database version 11.1
-- Dumped by pg_dump version 11.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: getRandomItems(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION public."getRandomItems"() RETURNS json[]
    LANGUAGE plpgsql
    AS $$DECLARE

  vJson json[];
  vAItem json;
  vSourceId integer[];
  vId integer;

BEGIN

	FOR vId IN
		(
			SELECT sou_id FROM source
  			ORDER BY RANDOM()
  			LIMIT 12
		) LOOP

    SELECT row_to_json(t)
    INTO vAItem
    FROM
    (
      SELECT *
      FROM item
      JOIN language ON ite_language=lan_id
      JOIN type ON ite_type=typ_id
      JOIN category ON ite_category=cat_id
      WHERE ite_source=vId
      ORDER BY RANDOM()
      LIMIT 1
    ) t ;

    vJson := array_append(vJson, vAItem);
  END LOOP;


  RETURN vJson;

END;$$;


ALTER FUNCTION public."getRandomItems"() OWNER TO postgres;


--
-- Name: insertNewItems(json, json); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE OR REPLACE PROCEDURE public."insertNewItems"("pSource" json, "pItems" json)
    LANGUAGE plpgsql
    AS $$
    DECLARE
      vAItem json;
      vNewId integer;
      vLangId integer;
      vCategoryId integer;
      vSourceId integer;
    BEGIN
        --INSERT INTO public.item VALUES (id, title, desc, type -> NULL, link,
        --                                datePub, lang, category, source);

        FOR vAItem in
        SELECT * FROM json_array_elements("pItems")
        --(SELECT ARRAY(pItems))
        --ARRAY(pItems)
        LOOP

            SELECT MAX(ite_id)+1 INTO vNewId FROM item;

            SELECT lan_id INTO vLangId
            FROM language
            WHERE lan_code=vAItem->>'language';

            SELECT cat_id INTO vCategoryId
            FROM category
            WHERE cat_lib=vAItem->>'category';

            INSERT INTO item VALUES
              (
                vNewId,
                vAItem->>'title',
                vAItem->>'description' ,
                NULL,
                vAItem->>'link',
                to_date(vAItem->>'datePub', 'YYYY-MM-DD'),
                vLangId,
                vCategoryId,
                to_number("pSource"->>'id', '99G999D9S')
              );
        END LOOP;
END;$$;


ALTER PROCEDURE public."insertNewItems"("pSource" json, "pItems" json) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;



--
-- Name: button; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.button (
    but_id integer NOT NULL,
    but_quote character varying(50)
);


ALTER TABLE public.button OWNER TO postgres;

--
-- Name: category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category (
    cat_id integer NOT NULL,
    cat_lib character varying(50)
);


ALTER TABLE public.category OWNER TO postgres;

--
-- Name: item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item (
    ite_id integer NOT NULL,
    ite_title character varying(250),
    ite_description character varying(400),
    ite_type integer,
    ite_link character varying(250),
    ite_datepub date,
    ite_language integer,
    ite_category integer,
    ite_source integer
);


ALTER TABLE public.item OWNER TO postgres;

--
-- Name: language; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.language (
    lan_id integer NOT NULL,
    lan_code character varying(5),
    lan_lib character varying(30)
);


ALTER TABLE public.language OWNER TO postgres;

--
-- Name: quote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quote (
    quo_id integer NOT NULL,
    quo_quote character varying(500)
);


ALTER TABLE public.quote OWNER TO postgres;

--
-- Name: source; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.source (
    sou_id integer NOT NULL,
    sou_name character varying(30),
    sou_link character varying(250)
);


ALTER TABLE public.source OWNER TO postgres;

--
-- Name: type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.type (
    typ_id integer NOT NULL,
    typ_lib character varying(30)
);


ALTER TABLE public.type OWNER TO postgres;

--
-- Data for Name: button; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.category VALUES (1, 'sport');
INSERT INTO public.category VALUES (2, 'technologie');


--
-- Data for Name: item; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.item VALUES (1, 'L’e-commerce français a crû de 6,13% en 2018', 'Le JDN a repéré les solutions les plus en pointe pour les magasins lors du NRF’s big show 2019. Découvrez le dernier épisode de notre série', 1, 'https://www.journaldunet.com/ebusiness/commerce/1421120-l-e-commerce-francais-croit-de-6-13-en-2018/', '2019-01-31', 1, 1, 1);
INSERT INTO public.item VALUES (2, 'Digital store : l’avatar connecté de Twenty Billion Neurons', 'Le nombre de transactions en ligne a augmenté de 12,79% sur un an. Le panier moyen annuel atteint 64,87 euros en 2018, en baisse de 4,07 euros par rapport à 2017.', 1, 'https://www.journaldunet.com/ebusiness/commerce/1421169-digital-store-l-avatar-connecte-de-twenty-billions-neurons/', '2019-01-31', 2, 2, 1);
INSERT INTO public.item VALUES (3, 'Digital Store : Zigzag Global facilite le retour des colis', 'Le JDN a repéré les solutions les plus en pointe pour les magasins lors du NRF’s big show 2019. Découvrez le septième épisode de notre série vidéo.', 2, 'https://www.journaldunet.com/ebusiness/commerce/1421084-digital-store-zigzag-global-pour-faciliter-les-retours-de-colis/', '2019-01-30', 1, 2, 1);
INSERT INTO public.item VALUES (4, 'Comment une gestion efficace des entrepôts peut sauver une vente ?', 'En pleine période de soldes, une attention particulière portée à la gestion de ses entrepôts permettrait aux commerçants de générer de nouvelles ventes et, point essentiel, de fidéliser leur clientèle. Explications.', 1, 'https://www.journaldunet.com/ebusiness/expert/70486/comment-une-gestion-efficace-des-entrepots-peut-sauver-une-vente.shtml', '2019-01-30', 2, 1, 1);
INSERT INTO public.item VALUES (5, 'Digital Store : Tompkins robotics et ses robots trieurs d’articles', 'Le JDN a repéré les solutions les plus en pointe pour les magasins lors du NRF’s big show 2019. Découvrez le sixième épisode de notre série vidéo.', 1, 'https://www.journaldunet.com/ebusiness/commerce/1421050-digital-store-tompkins-robotics-et-ses-robots-trieurs-d-articles/', '2019-01-29', 1, 1, 1);
INSERT INTO public.item VALUES (6, 'Facebook fête ses 15 ans d’existence', 'La plateforme fondée par un Mark Zuckerberg encore étudiant à Harvard a bien grandi. Elle a dépassé le cap des 2 milliards d’utilisateurs et celui des 50 milliards de dollars de chiffre d’affaires.', 2, 'https://www.journaldunet.com/media/publishers/1420930-facebook/', '2019-02-04', 1, 2, 2);
INSERT INTO public.item VALUES (7, 'Duel Google - Amazon : le marché publicitaire en pleine révolution ?', 'Leaders de leur marché respectif, Google et Amazon semblent engager depuis peu dans une dynamique concurrentielle intense. Après le cloud, l’assistant virtuel, voilà maintenant le secteur de la publicité digitale devenir le théâtre de leur affrontement. Search, display, e-commerce, focus sur 3 bouleversements en marche.', 1, 'https://www.journaldunet.com/ebusiness/expert/70504/duel-google---amazon---le-marche-publicitaire-en-pleine-revolution.shtml', '2019-02-04', 2, 1, 2);
INSERT INTO public.item VALUES (8, 'Profil Médiamétrie : les sites favoris des amateurs de cuisine', 'Les Foodistas sont particulièrement représentés dans les audiences de PtitChef, mais aussi dans celles du site sur les animaux de compagnie Wamiz et de l’e-commerçant Bon Prix, selon une étude de Médiamétrie//Netratings réalisée pour le JDN.', 1, 'https://www.journaldunet.com/ebusiness/marques-sites/1420825-profil-mediametrie-les-sites-favoris-des-amateurs-de-cuisine-selon-mediametrie/', '2019-01-31', 2, 1, 2);
INSERT INTO public.item VALUES (9, '43,1 millions de Français se sont connectés chaque jour à Internet en décembre', 'Le temps passé par jour et par individu est en moyenne de 31 minutes sur ordinateur et de 53 minutes sur mobile au cours du mois, selon le dernier baromètre de Médiamétrie//Netratings.', 1, 'https://www.journaldunet.com/media/publishers/1171756-audience-internet-france/', '2019-01-31', 1, 2, 2);
INSERT INTO public.item VALUES (10, 'Profil Médiamétrie : les sites préférés des early adopter', 'Flixbus, Zara et Deliveroo sont les trois marques le plus en affinité avec les early adopter, selon une étude exclusive Médiamétrie//Netratings pour le JDN.', 2, 'https://www.journaldunet.com/media/publishers/1421027-profil-mediametrie-les-sites-preferes-des-early-adopter/', '2019-01-30', 1, 1, 2);
INSERT INTO public.item VALUES (11, 'Les défis à relever dans le paiement en 2019', 'L’application de la directive sur les services de paiement, DSP2, est un des principaux challenges des acteurs du paiement en 2019. Mais pas que...', 2, 'https://www.journaldunet.com/economie/expert/70478/les-defis-a-relever-dans-le-paiement-en-2019.shtml', '2019-01-29', 1, 2, 3);
INSERT INTO public.item VALUES (12, 'Ronan Le Moal (Arkéa)  : "Notre assistant personnel Max vise les 100 000 clients d’ici fin 2019"', 'Le directeur général du groupe Crédit Mutuel Arkéa évoque ses chantiers en matière d’open banking et l’avenir de sa fintech interne Max.', 1, 'https://www.journaldunet.com/economie/finance/1420993-notre-assistant-personnel-max-vise-les-100-000-clients-d-ici-fin-2019/', '2019-01-29', 1, 1, 3);
INSERT INTO public.item VALUES (13, 'Charles Egly (Younited Credit)  : "Nous avons octroyé plus de 20 000 crédits pour la nouvelle Freebox"', 'Sept ans après sa création, la plateforme de crédit conso Younited Credit passe le cap du milliard de prêts accordés. Un montant fruit de son expansion internationale et de l’accélération de son activité BtoB.', 2, 'https://www.journaldunet.com/economie/finance/1421023-nous-avons-octroye-plus-de-20-000-credits-pour-la-nouvelle-freebox/', '2019-01-29', 1, 1, 3);
INSERT INTO public.item VALUES (14, 'Crowdfunding : définition, sites, marché de l’immobilier…', 'Le financement participatif, rendu populaire notamment par KissKissBankBank et Ulule, permet aux particuliers et professionnels de lever des fonds pour un projet.', 2, 'https://www.journaldunet.com/economie/finance/1196225-crowdfunding-definition-sites-marche-de-l-immobilier/', '2019-01-28', 2, 1, 3);
INSERT INTO public.item VALUES (15, 'Ce qui attend la fintech en 2019', 'Open banking, détection de la fraude, internationalisation... l’année 2019 sera encore pleine de défis pour les fintech.', 1, 'https://www.journaldunet.com/economie/expert/70448/ce-qui-attend-la-fintech-en-2019.shtml', '2019-01-25', 2, 1, 3);
INSERT INTO public.item VALUES (16, 'Smart home : quelle place pour la voix dans la domotique ?', 'L’usage naturel de la voix va transformer la domotique et promet d’accélérer significativement l’équipement des maisons. Cet essor devra néanmoins s’accompagner d’une protection efficace des données personnelles collectées.', 2, 'https://www.journaldunet.com/ebusiness/expert/70494/smart-home---quelle-place-pour-la-voix-dans-la-domotique.shtml', '2019-01-30', 1, 2, 4);
INSERT INTO public.item VALUES (17, 'Comment le marché du réseau doit évoluer en 2019 ?', 'L’internet des objets (IoT), l’automatisation, la nouvelle norme Wi-Fi et, bien sûr, la sécurité des réseaux restent indispensables à la bonne marche des entreprises du networking.', 1, 'https://www.journaldunet.com/ebusiness/expert/70483/comment-le-marche-du-reseau-doit-evoluer-en-2019.shtml', '2019-01-30', 2, 1, 4);
INSERT INTO public.item VALUES (18, 'Avec l’IoT, l’agroalimentaire commence à structurer ses données', 'Pour répondre aux enjeux d’une alimentation de qualité et transparente, les acteurs du secteur doivent recouper les informations de leurs capteurs et les partager avec leurs partenaires.', 1, 'https://www.journaldunet.com/ebusiness/internet-mobile/1421068-avec-l-iot-l-agroalimentaire-commence-a-structurer-ses-donnees/', '2019-01-29', 2, 2, 4);
INSERT INTO public.item VALUES (19, 'Thierry Chambon (Energisme)  : "Nous levons 11 millions d’euros pour développer l’IA de notre plateforme IoT"', 'Energisme, qui propose des tableaux de bord pour la maîtrise énergétique dans le secteur B2B, entend garantir aux entreprises une connaissance de leurs données de consommation.', 1, 'https://www.journaldunet.com/ebusiness/internet-mobile/1420995-thierry-chambon-pdg-energisme/', '2019-01-29', 1, 1, 4);
INSERT INTO public.item VALUES (20, 'Le potentiel de l’Internet des objet sera-t-il optimisé grâce à l’interconnexion ?', 'Selon le cabinet Gartner, 95 % des nouveaux produits électroniques intégreront en 2020 des technologies liées à l’Internet des objets (IoT). Ce dernier se fait de plus en plus présent dans notre quotidien et cessera bientôt d’être une tendance d’avenir pour devenir un des principaux agitateurs de l’économie numérique mondiale.', 1, 'https://www.journaldunet.com/ebusiness/expert/70432/le-potentiel-de-l-internet-des-objet-sera-t-il-optimise-grace-a-l-interconnexion.shtml', '2019-01-22', 2, 1, 4);
INSERT INTO public.item VALUES (21, 'Comment Los Angeles a redynamisé son centre-ville déserté', 'Avant les JO 2028, Los Angeles se réinvente  (1/4) — Face à ses rivales américaines New-York et San Francisco, Los Angeles réaménagé son centre-ville pour attirer les forces vives du pays et d’ailleurs.', 2, 'https://www.journaldunet.com/economie/expert/70456/comment-los-angeles-a-redynamise-son-centre-ville-deserte.shtml', '2019-01-28', 1, 2, 5);
INSERT INTO public.item VALUES (22, 'La smart city transforme l’activité des énergéticiens', 'Pour tirer parti de l’essor des villes intelligentes, les énergéticiens se positionnent sur le créneau de la durabilité et font évoluer leurs métiers et leurs activités.', 1, 'https://www.journaldunet.com/economie/expert/70430/la-smart-city-transforme-l-activite-des-energeticiens.shtml', '2019-01-28', 2, 2, 5);
INSERT INTO public.item VALUES (23, 'La Smart City au cœur du nouveau contrat social', 'La ville intelligente jouera un rôle fondamental dans la rénovation du vivre ensemble et de la démocratie participative. Cependant, la réflexion de fond sur le sens que les pouvoirs publics souhaitent lui donner reste à engager.', 2, 'https://www.journaldunet.com/economie/expert/70258/la-smart-city-au-c-ur-du-nouveau-contrat-social.shtml', '2018-12-21', 1, 1, 5);
INSERT INTO public.item VALUES (24, 'La ville intelligente de demain sera-t-elle durable ?', 'Avec l’avènement des nouvelles technologies les villes sont davantage connectées et promettent d’être plus performantes grâce à leurs infrastructures, transports ou écosystèmes toujours plus innovants.', 2, 'https://www.journaldunet.com/economie/expert/70197/la-ville-intelligente-de-demain-sera-t-elle-durable.shtml', '2018-12-10', 2, 1, 5);
INSERT INTO public.item VALUES (25, 'Trois collectivités et un dessein : convertir la région nantaise à l’open data', 'Nantes Métropole, le département Loire-Atlantique et la région Pays de La Loire veulent faire profiter les petites communes de leur portail de données commun pour les aider à respecter la loi.', 2, 'https://www.journaldunet.com/economie/services/1418259-nantes-metropole-pays-de-la-loire-loi-atlantique-open-data/', '2018-11-07', 2, 2, 5);
INSERT INTO public.item VALUES (26, 'Les recrutements des ESN en 2019', 'Quels sont les profils recherchés par les entreprises de services du numérique en France pour 2019 ? Quelles compétences sont-elles ciblées ? Quid des postes à pourvoir en régions ? Tour d’horizon.', 2, 'https://www.journaldunet.com/management/emploi-cadres/1207439-les-recrutements-des-ssii-esn-en-2019/', '2019-01-22', 2, 1, 1);
INSERT INTO public.item VALUES (27, 'Le marché de la création d’entreprise en ligne en voie de consolidation', 'Depuis quelques années, plusieurs start-up proposent de créer sa société via leur portail web. Dans un marché presque arrivé à maturité, elles cherchent à se diversifier.', 2, 'https://www.journaldunet.com/management/creation-entreprise/1420291-le-marche-de-la-creation-d-entreprise-en-ligne-en-voie-de-consolidation/', '2018-12-21', 1, 1, 2);
INSERT INTO public.item VALUES (28, 'Recrutement automatisé : des algorithmes pour détecter les softs skills', 'Pour recruter, les DRH peuvent se baser sur l’utilisation de données, y compris sur les compétences humaines des candidats. Des entreprises ont investi ce créneau.', 1, 'https://www.journaldunet.com/management/ressources-humaines/1420097-recrutement-automatise-des-algorithmes-pour-detecter-les-softs-skills/', '2018-12-17', 1, 2, 3);
INSERT INTO public.item VALUES (29, 'Start-up et grands groupes de la paie prêts pour le prélèvement à la source', '#Les éditeurs de logiciels RH et de paie sont en première ligne pour accompagner les entreprises dans l’application du prélèvement à la source. Notamment pour leur communication interne.', 2, 'https://www.journaldunet.com/management/salaire-cadres/1419709-les-start-up-et-grands-groupes-de-la-paie-prets-pour-le-prelevement-a-la-source/', '2018-12-10', 2, 1, 4);
INSERT INTO public.item VALUES (30, 'Emeline Bissoni (Automatic Data Processing) : "Gérer la paie de 40 millions de personnes implique de protéger sérieusement leurs données personnelles"', 'Alors que la Nuit du data protection officer approche, la DPO du spécialiste de la gestion de paie fait le point sur ses chantiers.', 1, 'https://www.journaldunet.com/management/ressources-humaines/1419631-emeline-bissoni-automatic-data-processing/', '2018-12-07', 1, 2, 5);


--
-- Data for Name: language; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.language VALUES (1, 'af', 'Afrikaans');
INSERT INTO public.language VALUES (2, 'sq', 'Albanian');
INSERT INTO public.language VALUES (3, 'eu', 'Basque');
INSERT INTO public.language VALUES (4, 'be', 'Belarusian');
INSERT INTO public.language VALUES (5, 'bg', 'Bulgarian');
INSERT INTO public.language VALUES (6, 'ca', 'Catalan');
INSERT INTO public.language VALUES (7, 'zh-cn', 'Chinese (Simplified)');
INSERT INTO public.language VALUES (8, 'zh-tw', 'Chinese (Traditional)');
INSERT INTO public.language VALUES (9, 'hr', 'Croatian');
INSERT INTO public.language VALUES (10, 'cs', 'Czech');
INSERT INTO public.language VALUES (11, 'da', 'Danish');
INSERT INTO public.language VALUES (12, 'nl', 'Dutch');
INSERT INTO public.language VALUES (13, 'nl-be', 'Dutch (Belgium)');
INSERT INTO public.language VALUES (14, 'nl-nl', 'Dutch (Netherlands)');
INSERT INTO public.language VALUES (15, 'en', 'English');
INSERT INTO public.language VALUES (16, 'en-au', 'English (Australia)');
INSERT INTO public.language VALUES (17, 'en-bz', 'English (Belize)');
INSERT INTO public.language VALUES (18, 'en-ca', 'English (Canada)');
INSERT INTO public.language VALUES (19, 'en-ie', 'English (Ireland)');
INSERT INTO public.language VALUES (20, 'en-jm', 'English (Jamaica)');
INSERT INTO public.language VALUES (21, 'en-nz', 'English (New Zealand)');
INSERT INTO public.language VALUES (22, 'en-ph', 'English (Phillipines)');
INSERT INTO public.language VALUES (23, 'en-za', 'English (South Africa)');
INSERT INTO public.language VALUES (24, 'en-tt', 'English (Trinidad)');
INSERT INTO public.language VALUES (25, 'en-gb', 'English (United Kingdom)');
INSERT INTO public.language VALUES (26, 'en-us', 'English (United States)');
INSERT INTO public.language VALUES (27, 'en-zw', 'English (Zimbabwe)');
INSERT INTO public.language VALUES (28, 'et', 'Estonian');
INSERT INTO public.language VALUES (29, 'fo', 'Faeroese');
INSERT INTO public.language VALUES (30, 'fi', 'Finnish');
INSERT INTO public.language VALUES (31, 'fr', 'French');
INSERT INTO public.language VALUES (32, 'fr-be', 'French (Belgium)');
INSERT INTO public.language VALUES (33, 'fr-ca', 'French (Canada)');
INSERT INTO public.language VALUES (34, 'fr-fr', 'French (France)');
INSERT INTO public.language VALUES (35, 'fr-lu', 'French (Luxembourg)');
INSERT INTO public.language VALUES (36, 'fr-mc', 'French (Monaco)');
INSERT INTO public.language VALUES (37, 'fr-ch', 'French (Switzerland)');
INSERT INTO public.language VALUES (38, 'gl', 'Galician');
INSERT INTO public.language VALUES (39, 'gd', 'Gaelic');
INSERT INTO public.language VALUES (40, 'de', 'German');
INSERT INTO public.language VALUES (41, 'de-at', 'German (Austria)');
INSERT INTO public.language VALUES (42, 'de-de', 'German (Germany)');
INSERT INTO public.language VALUES (43, 'de-li', 'German (Liechtenstein)');
INSERT INTO public.language VALUES (44, 'de-lu', 'German (Luxembourg)');
INSERT INTO public.language VALUES (45, 'de-ch', 'German (Switzerland)');
INSERT INTO public.language VALUES (46, 'el', 'Greek');
INSERT INTO public.language VALUES (47, 'haw', 'Hawaiian');
INSERT INTO public.language VALUES (48, 'hu', 'Hungarian');
INSERT INTO public.language VALUES (49, 'is', 'Icelandic');
INSERT INTO public.language VALUES (50, 'in', 'Indonesian');
INSERT INTO public.language VALUES (51, 'ga', 'Irish');
INSERT INTO public.language VALUES (52, 'it', 'Italian');
INSERT INTO public.language VALUES (53, 'it-it', 'Italian (Italy)');
INSERT INTO public.language VALUES (54, 'it-ch', 'Italian (Switzerland)');
INSERT INTO public.language VALUES (55, 'ja', 'Japanese');
INSERT INTO public.language VALUES (56, 'ko', 'Korean');
INSERT INTO public.language VALUES (57, 'mk', 'Macedonian');
INSERT INTO public.language VALUES (58, 'no', 'Norwegian');
INSERT INTO public.language VALUES (59, 'pl', 'Polish');
INSERT INTO public.language VALUES (60, 'pt', 'Portuguese');
INSERT INTO public.language VALUES (61, 'pt-br', 'Portuguese (Brazil)');
INSERT INTO public.language VALUES (62, 'pt-pt', 'Portuguese (Portugal)');
INSERT INTO public.language VALUES (63, 'ro', 'Romanian');
INSERT INTO public.language VALUES (64, 'ro-mo', 'Romanian (Moldova)');
INSERT INTO public.language VALUES (65, 'ro-ro', 'Romanian (Romania)');
INSERT INTO public.language VALUES (66, 'ru', 'Russian');
INSERT INTO public.language VALUES (67, 'ru-mo', 'Russian (Moldova)');
INSERT INTO public.language VALUES (68, 'ru-ru', 'Russian (Russia)');
INSERT INTO public.language VALUES (69, 'sr', 'Serbian');
INSERT INTO public.language VALUES (70, 'sk', 'Slovak');
INSERT INTO public.language VALUES (71, 'sl', 'Slovenian');
INSERT INTO public.language VALUES (72, 'es', 'Spanish');
INSERT INTO public.language VALUES (73, 'es-ar', 'Spanish (Argentina)');
INSERT INTO public.language VALUES (74, 'es-bo', 'Spanish (Bolivia)');
INSERT INTO public.language VALUES (75, 'es-cl', 'Spanish (Chile)');
INSERT INTO public.language VALUES (76, 'es-co', 'Spanish (Colombia)');
INSERT INTO public.language VALUES (77, 'es-cr', 'Spanish (Costa Rica)');
INSERT INTO public.language VALUES (78, 'es-do', 'Spanish (Dominican Republic)');
INSERT INTO public.language VALUES (79, 'es-ec', 'Spanish (Ecuador)');
INSERT INTO public.language VALUES (80, 'es-sv', 'Spanish (El Salvador)');
INSERT INTO public.language VALUES (81, 'es-gt', 'Spanish (Guatemala)');
INSERT INTO public.language VALUES (82, 'es-hn', 'Spanish (Honduras)');
INSERT INTO public.language VALUES (83, 'es-mx', 'Spanish (Mexico)');
INSERT INTO public.language VALUES (84, 'es-ni', 'Spanish (Nicaragua)');
INSERT INTO public.language VALUES (85, 'es-pa', 'Spanish (Panama)');
INSERT INTO public.language VALUES (86, 'es-py', 'Spanish (Paraguay)');
INSERT INTO public.language VALUES (87, 'es-pe', 'Spanish (Peru)');
INSERT INTO public.language VALUES (88, 'es-pr', 'Spanish (Puerto Rico)');
INSERT INTO public.language VALUES (89, 'es-es', 'Spanish (Spain)');
INSERT INTO public.language VALUES (90, 'es-uy', 'Spanish (Uruguay)');
INSERT INTO public.language VALUES (91, 'es-ve', 'Spanish (Venezuela)');
INSERT INTO public.language VALUES (92, 'sv', 'Swedish');
INSERT INTO public.language VALUES (93, 'sv-fi', 'Swedish (Finland)');
INSERT INTO public.language VALUES (94, 'sv-se', 'Swedish (Sweden)');
INSERT INTO public.language VALUES (95, 'tr', 'Turkish');
INSERT INTO public.language VALUES (96, 'uk', 'Ukranian');


--
-- Data for Name: quote; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: source; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.source VALUES (1, 'journal du net', 'https://www.journaldunet.com');
INSERT INTO public.source VALUES (2, 'random news', 'https://www.randomnews.com');
INSERT INTO public.source VALUES (3, 'le journal du hard', 'https://www.lejournalduhard.com');
INSERT INTO public.source VALUES (4, 'lanruoj el', 'https://www.lanruojel.com');
INSERT INTO public.source VALUES (5, 'gepludide', 'https://www.gepludide.com');


--
-- Data for Name: type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.type VALUES (1, 'image');
INSERT INTO public.type VALUES (2, 'article');


--
-- Name: button button_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.button
    ADD CONSTRAINT button_pkey PRIMARY KEY (but_id);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (cat_id);


--
-- Name: item item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_pkey PRIMARY KEY (ite_id);


--
-- Name: language language_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.language
    ADD CONSTRAINT language_pkey PRIMARY KEY (lan_id);


--
-- Name: quote quote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quote
    ADD CONSTRAINT quote_pkey PRIMARY KEY (quo_id);


--
-- Name: source source_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source
    ADD CONSTRAINT source_pkey PRIMARY KEY (sou_id);


--
-- Name: type type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type
    ADD CONSTRAINT type_pkey PRIMARY KEY (typ_id);


--
-- Name: item item_ite_language_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_ite_language_fkey FOREIGN KEY (ite_language) REFERENCES public.language(lan_id);


--
-- Name: item item_ite_source_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_ite_source_fkey FOREIGN KEY (ite_source) REFERENCES public.source(sou_id);


--
-- Name: item item_ite_category_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_ite_category_fkey FOREIGN KEY (ite_category) REFERENCES public.category(cat_id);


--
-- Name: item item_ite_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_ite_type_fkey FOREIGN KEY (ite_type) REFERENCES public.type(typ_id);


--
-- PostgreSQL database dump complete
--
