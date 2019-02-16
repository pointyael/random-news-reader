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
  vSourceId integer;

BEGIN

	FOR vSourceId IN
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
      WHERE ite_source=vSourceId
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

        FOR vAItem in
          SELECT * FROM json_array_elements("pItems")
        LOOP

            SELECT MAX(ite_id)+1 INTO vNewId FROM item;

            SELECT lan_id INTO vLangId
            FROM language
            WHERE lan_code=vAItem->>'language';

            SELECT cat_id INTO vCategoryId
            FROM category
            WHERE cat_lib=vAItem->>'category';

            INSERT INTO public.item VALUES
              (
                vNewId,
                vAItem->>'title',
                vAItem->>'description' ,
                vAItem->>'enclosure',
                NULL,
                vAItem->>'link',
                to_timestamp(vAItem->>'pubDate', 'Dy, DD Mon YYYY HH24:MI:SS'),
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

CREATE TABLE public.buttonQuote (
    but_id integer NOT NULL,
    but_quote character varying(50)
);


ALTER TABLE public.buttonQuote OWNER TO postgres;

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
    ite_description character varying(1000),
    ite_enclosure character varying(400),
    ite_type integer,
    ite_link character varying(250),
    ite_pubdate timestamp,
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
-- Name: mot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mot (
    mot_id integer NOT NULL,
    mot_lib character varying(50),
    mot_freq integer,
    mot_language integer
);


ALTER TABLE public.mot OWNER TO postgres;


--
-- Name: quote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sidebarQuote (
    quo_id integer NOT NULL,
    quo_quote character varying(500)
);


ALTER TABLE public.sidebarQuote OWNER TO postgres;

--
-- Name: source; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.source (
    sou_id integer NOT NULL,
    sou_title character varying(30),
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

INSERT INTO public.buttonQuote VALUES (1, 'Encore !');
INSERT INTO public.buttonQuote VALUES (2, 'Moins de chats !');
INSERT INTO public.buttonQuote VALUES (3, 'Plus de chats !');
INSERT INTO public.buttonQuote VALUES (4, 'Moins de licornes !');
INSERT INTO public.buttonQuote VALUES (5, 'Plus de licornes !');
INSERT INTO public.buttonQuote VALUES (6, 'C’est nul...');
INSERT INTO public.buttonQuote VALUES (7, 'Je m’ennuie...');
INSERT INTO public.buttonQuote VALUES (8, 'Cap’ de tout ?');
INSERT INTO public.buttonQuote VALUES (9, 'Appuyez fort.');
INSERT INTO public.buttonQuote VALUES (10, 'Appuyez plus fort !');
INSERT INTO public.buttonQuote VALUES (11, 'Ça marche paaas !');
INSERT INTO public.buttonQuote VALUES (12, 'Ça marche toujours pas !');
INSERT INTO public.buttonQuote VALUES (13, 'Ça marche mal...');
INSERT INTO public.buttonQuote VALUES (14, 'Reloading !');
INSERT INTO public.buttonQuote VALUES (15, 'Je suis un bouton.');
INSERT INTO public.buttonQuote VALUES (16, 'Clique !');
INSERT INTO public.buttonQuote VALUES (17, 'Doh !');
INSERT INTO public.buttonQuote VALUES (18, 'Expelliarmus !');
INSERT INTO public.buttonQuote VALUES (19, 'FUS RO DAH !');
INSERT INTO public.buttonQuote VALUES (20, 'Rush B !');
INSERT INTO public.buttonQuote VALUES (21, 'Just Monika.');
INSERT INTO public.buttonQuote VALUES (22, 'Une simple pression.');
INSERT INTO public.buttonQuote VALUES (23, 'Oups...');
INSERT INTO public.buttonQuote VALUES (24, 'Ne pas toucher.');
INSERT INTO public.buttonQuote VALUES (25, 'Gogogadgeto actualisation !');
INSERT INTO public.buttonQuote VALUES (26, 'Wazaaa !');
INSERT INTO public.buttonQuote VALUES (27, 'Et caetera.');
INSERT INTO public.buttonQuote VALUES (28, 'Nani ?');
INSERT INTO public.buttonQuote VALUES (30, 'Tour gratuit.');
INSERT INTO public.buttonQuote VALUES (31, 'Un autre !');
INSERT INTO public.buttonQuote VALUES (32, 'I’ll be back.');
INSERT INTO public.buttonQuote VALUES (33, 'La roue tourne a tourné.');
INSERT INTO public.buttonQuote VALUES (34, 'Pas intéressé ?');
INSERT INTO public.buttonQuote VALUES (35, 'Essaye encore !');
INSERT INTO public.buttonQuote VALUES (36, 'Essaye pour voir.');
INSERT INTO public.buttonQuote VALUES (37, 'Nop.');
INSERT INTO public.buttonQuote VALUES (38, 'Rien.');
INSERT INTO public.buttonQuote VALUES (39, 'Pouf !');
INSERT INTO public.buttonQuote VALUES (40, 'Au suivant ?');
INSERT INTO public.buttonQuote VALUES (41, 'Un p’tit clic ?');
INSERT INTO public.buttonQuote VALUES (42, 'Swap !');
INSERT INTO public.buttonQuote VALUES (43, 'Tout oublier.');
INSERT INTO public.buttonQuote VALUES (44, '');


--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.category VALUES (1, 'sport');
INSERT INTO public.category VALUES (2, 'technologie');


--
-- Data for Name: item; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(2, 'Ligue du LOL : après Vincent Glad et David Doucet, les noms des membres traqués',' ',1,'https://www.linternaute.com/actualite/societe/1778944-ligue-du-lol-qui-sont-les-membres-de-ce-collectif/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/otyopbeAmfp4dUghjRoHOPUEDMk=/1280x/smart/7f048ada8ba743bf9b41f3d563d8e144/ccmcms-linternaute/11039619.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(3, 'Elections européennes 2019 : date, sondage, candidats... Tout savoir',' ',1,'https://www.linternaute.com/actualite/politique/1447387-elections-europeennes-2019-lr-se-lance-actus-sondage-date-candidats/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/1BE9uNqpiXtXg6QcyGJi0u0eMd0=/1280x/smart/073f007710bd4ceb979a0d0d5b0d7b75/ccmcms-linternaute/11025865.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(4, 'Cadeau de Noël pour ado : des idées (vraiment bonnes) pour les jeunes',' ',1,'https://www.linternaute.com/actualite/societe/1421509-cadeau-de-noel-pour-ado-des-idees-vraiment-bonnes-pour-les-jeunes/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/bPJQKBREqHgjb1TKzh2Wl9rSsxc=/1280x/smart/bf243105ad2246858335c755e15e74b4/ccmcms-linternaute/10995837.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(5, 'De trader à humoriste, qui est vraiment François-Xavier Demaison ?',' ',1,'https://www.linternaute.com/cinema/star-cinema/1779080-de-trader-a-humoriste-qui-est-vraiment-francois-xavier-demaison/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/0GUv7GHkWJWK7xlwOFrWNnvdWeI=/1280x/smart/c1fe9322e287463090f2d4bff14f7843/ccmcms-linternaute/11040005.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(6, 'Crise des gilets jaunes : un acte 14 samedi et dimanche ?',' ',1,'https://www.linternaute.com/actualite/politique/1756762-crise-des-gilets-jaunes-un-acte-14-samedi-et-dimanche/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/wG88tfkgi7DtfC6Ws8q0UzoSv5w=/1280x/smart/8dbbbe5a58ec46b39b6b7c48b3008e45/ccmcms-linternaute/11039753.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(7, 'Renault F1 : la RS19 dévoilée, les photos de la F1 2019',' ',1,'http://www.linternaute.com/auto/magazine/1282102-renault-f1-la-rs19-presentee-les-photos-et-infos-de-la-f1-2019/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/MdjwngjjNK6dZ2AJhMgTtZGC1Ew=/1280x/smart/74aca18397a942bf9a2d2f67b9fbcfc7/ccmcms-linternaute/11040008.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(8, 'La nouvelle F1 de Renault, la RS19, en images',' ',1,'https://www.linternaute.com/auto/magazine/1779190-la-nouvelle-f1-de-renault-la-rs19-en-images/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/8UsOH6avhK_97FfpYArXwgYlcMo=/1280x/smart/51b24fdd78624ad689ff0f264b99b796/ccmcms-linternaute/11039973.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(9, 'Rentrée scolaire 2019 : date, actus, nouveautés et coût',' ',1,'https://www.linternaute.com/actualite/education/1243286-rentree-scolaire-2019-la-date-et-les-actus/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/BTqacoJa-Uk5vG2vzgGa5pLcfRc=/1280x/smart/9ff90738dd83453e941fcd0975fce2e5/ccmcms-linternaute/11039997.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(10, 'Espagne : début du procès historique des dirigeants indépendantistes catalans',' ',1,'https://www.linternaute.com/actualite/depeches/1779036-espagne-debut-du-proces-historique-des-dirigeants-independantistes-catalans/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/TZLGPxfb0cmQcu7Xvxpf_h8xLHs=/1280x/smart/05d3702bd5da42269b574919a9e97266/ccmcms-linternaute/11039972.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(11, 'Syrie: poursuite de violents combats dans lultime réduit de lEI',' ',1,'https://www.linternaute.com/actualite/depeches/1779186-syrie-des-centaines-de-civils-fuient-les-combats-dans-l-ultime-reduit-de-l-ei/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/z7v4Xmyi0Tp8K-HUVQz_XojIVno=/1280x/smart/67b930e8e3a047cb8f15bd473a394932/ccmcms-linternaute/11039960.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(12, 'Venezuela: nouvelle mobilisation pour exiger lentrée de laide, à lappel de lopposition',' ',1,'https://www.linternaute.com/actualite/depeches/1778852-venezuela-guaido-avertit-l-armee-que-bloquer-l-aide-est-un-crime-contre-l-humanite/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/W7Z98q8usJTq8g2VO0LFFjSMiRo=/1280x/smart/7d4db8d31f70499c9edc57fda4591d31/ccmcms-linternaute/11039943.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(13, 'Etats-Unis: percée au Congrès pour éviter un nouveau shutdown',' ',1,'https://www.linternaute.com/actualite/depeches/1779044-trump-vante-le-mur-a-el-paso-percee-au-congres/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/bNfkElSmdsWuYiAyePRJ48kxvhQ=/1280x/smart/5cfdbae972af417ca2535450fa38fb36/ccmcms-linternaute/11040004.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(14, 'Expo Toutânkhamon : découvrez les oeuvres en avant-première',' ',1,'https://www.linternaute.com/sortir/guide-des-loisirs/1762890-expo-toutankhamon-decouvrez-les-oeuvres-en-avant-premiere/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/dGKwDLIUeAnpGYsdmfD00bEw5_8=/1280x/smart/da301a3e72ed40e7913b4509661ed3fe/ccmcms-linternaute/11039876.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(15, 'Condamnations unanimes après le bond des actes antisémites',' ',1,'https://www.linternaute.com/actualite/depeches/1779188-condamnations-unanimes-apres-le-bond-des-actes-antisemites/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/Ak5U4djVQuROKViX81zS_PSNAjk=/1280x/smart/fba1714feca24659a6cc1dfdcc976658/ccmcms-linternaute/11039937.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(16, 'Mort de Gordon Banks, le gardien qui a écoeuré le roi Pelé',' ',1,'https://www.linternaute.com/actualite/depeches/1389897-orages-17-departements-en-vigilance-orange/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/ZB9QcDN605AbFXtqdeLe8k6BuZI=/1280x/smart/58653c0a0800435eb53cc43dbf389c02/ccmcms-linternaute/11039955.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(17, 'Des boues rouges de lusine Alteo devant le ministère de lEcologie',' ',1,'https://www.linternaute.com/actualite/depeches/1779046-des-boues-rouges-de-l-usine-alteo-devant-le-ministere-de-l-ecologie/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/WyxKdfuh_zj5rsvf5zUVOxQtdQo=/1280x/smart/5187bcd2e9504ffa8813aac7e36449dd/ccmcms-linternaute/11039874.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(18, 'Permis de conduire : le permis dès 17 ans, moins cher avec la réforme ?',' ',1,'https://www.linternaute.com/auto/guide-pratique-auto/1409150-permis-de-conduire-sera-t-il-moins-cher-ce-que-la-reforme-prevoit/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/bVakaj3ggK0VRVbY0rEAVIIi6eE=/1280x/smart/bc7185f4aac5442ca0a3a2179567a092/ccmcms-linternaute/11039818.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(19, 'Classement des lycées 2019 : un premier palmarès déjà établi, les chiffres clés',' ',1,'https://www.linternaute.com/actualite/education/1368870-classement-des-lycees-2019-un-premier-palmares-deja-etabli-les-chiffres-cles/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/coZn1V4GQHlvdOXM3ASADoYOEsk=/1280x/smart/93cf1a71df044cb4bb666375a68fb26c/ccmcms-linternaute/11039870.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(20, 'Intrusion au ministère de Griveaux par des gilets jaunes: six personnes interpellées',' ',1,'https://www.linternaute.com/actualite/depeches/1779048-intrusion-au-ministere-de-griveaux-par-des-gilets-jaunes-quatre-personnes-interpellees/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/j9z46dWaen_djJ34LbUsj9fMxp4=/1280x/smart/129468a4a64b4c4eb66d48bdefe3bfd3/ccmcms-linternaute/11039863.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(21, 'Au Théâtre des rêves de Manchester, le PSG espère briser sa malédiction européenne',' ',1,'https://www.linternaute.com/actualite/depeches/1779038-au-theatre-des-reves-de-manchester-le-psg-veut-s-eviter-un-cauchemar-europeen/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/_y8i4vynLQE950FJmzWrTi06CV4=/1280x/smart/7f24a947b3f6453585d57f9c533df1a4/ccmcms-linternaute/11040043.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(22, 'Musée Grévin 2019 : 30 nouvelles stars en cire ont investi les lieux',' ',1,'https://www.linternaute.com/sortir/guide-des-loisirs/1414839-musee-grevin-2019-30-nouvelles-stars-en-cire-ont-investi-les-lieux/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/Tw1d4JkBRjhkhnS__a-emLTrHoY=/1280x/smart/e9ca957e52e74eaab54da454f481ac29/ccmcms-linternaute/11034168.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(23, 'Résultat de lEuromillion (FDJ) : le tirage du mardi 12 février 2019, cest 151 millions !',' ',1,'https://www.linternaute.com/actualite/societe/1779182-resultat-de-l-euromillion-fdj-le-tirage-du-mardi-12-fevrier-2019-c-est-151-millions/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/DGdkIHQJGRBvtFlgqeRj5vn_gSM=/1280x/smart/c74056259b3b443481964c5f4d77bef3/ccmcms-linternaute/11039851.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(24, 'Équinoxe de printemps 2019 : définition, date et fête païenne',' ',1,'https://www.linternaute.com/actualite/societe/1218670-equinoxe-de-printemps-la-meteo-qui-vous-attend-cette-semaine/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/g0d-kv86QpBtO9Kg6c5mwx9v30k=/1280x/smart/ec6fd5e50ab44d5594fc1735413758dd/ccmcms-linternaute/11039835.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(25, 'Policiers tués à Magnanville en 2016: deux hommes en garde à vue',' ',1,'https://www.linternaute.com/actualite/depeches/1779184-policiers-tues-a-magnanville-en-2016-deux-hommes-en-garde-a-vue/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/IysqHgw3kyqlMvk4Wn4xX6VI1G4=/1280x/smart/fb62bd3742524eb7ba62ab535a211b9a/ccmcms-linternaute/11040001.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(26, 'Chocolat : le petit-fils de Charlie Chaplin joue avec Omar Sy !',' ',1,'https://www.linternaute.com/television/chocolat-le-petit-fils-de-charlie-chaplin-joue-avec-omar-sy-p3721924/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/g-TDaY5YsapqMfmQAHXlvjZpbOw=/1280x/smart/263b8fd81acd4d0990bd746f3c663fde/ccmcms-linternaute/11039817.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(27, 'Démission dIsmaël Emelien : pourquoi fait-on le lien avec Benalla ?',' ',1,'https://www.linternaute.com/actualite/personnalites/1779042-emelien-des-liens-avec-l-affaire-benalla/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/7XOpu7k7ODXNVS-jpY8_jIvnMgE=/1280x/smart/e7bd51b7a7654d71a9701e4d76712d4a/ccmcms-linternaute/11039614.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(28, '12 coups de midi : les indices sur létoile mystérieuse',' ',1,'https://www.linternaute.com/television/12-coups-de-midi-les-indices-sur-l-etoile-mysterieuse-p3119439/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/2zw6bqJLUj0ihCKPKyFyTVWemaY=/1280x/smart/2076d088c0ed451ead0ef19db7e15e0b/ccmcms-linternaute/11039811.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(29, 'Journée internationale des droits des femmes 2019 : des citations et son histoire',' ',1,'https://www.linternaute.com/actualite/societe/1272879-journee-internationale-des-droits-des-femmes-2019-des-citations-et-son-histoire/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/qQ9bW8PhqnMCbeGpFTGF7EAIBqI=/1280x/smart/8b7ad3a2f4d6497abe04568071d00457/ccmcms-linternaute/11039807.jpg');
INSERT INTO public.item (ite_id, ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES(30, 'La Saint-Valentin, fashion week des roses dEquateur',' ',1,'https://www.linternaute.com/actualite/depeches/1779118-la-saint-valentin-fashion-week-des-roses-d-equateur/',' 2011-02-4',1, 2, 1,'https://img-4.linternaute.com/IeDRS1K1Pahdkfnnv_lDVGjBykk=/1280x/smart/6a2a17a0553f486ea30654115e85cc1a/ccmcms-linternaute/11039768.jpg');


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

INSERT INTO public.sidebarQuote VALUES (1, 'Il ne restera pas grand-chose.');
INSERT INTO public.sidebarQuote VALUES (2, 'Sortez du bocal.');
INSERT INTO public.sidebarQuote VALUES (3, 'Oubliez avant d’être lu.');
INSERT INTO public.sidebarQuote VALUES (4, 'Le rédac’ chef est malade.');
INSERT INTO public.sidebarQuote VALUES (5, 'Personne aux commandes.');
INSERT INTO public.sidebarQuote VALUES (6, 'Pourquoi lire tout ça ?');
INSERT INTO public.sidebarQuote VALUES (7, 'Il ne se passe jamais rien...');
INSERT INTO public.sidebarQuote VALUES (8, 'On vous ment pas !');
INSERT INTO public.sidebarQuote VALUES (9, 'Trié par le vent.');
INSERT INTO public.sidebarQuote VALUES (10, 'Choisir, c’est exclure !');
INSERT INTO public.sidebarQuote VALUES (11, 'Personne ne lit ça de toute façon...');
INSERT INTO public.sidebarQuote VALUES (12, 'Va falloir choisir !');
INSERT INTO public.sidebarQuote VALUES (13, 'Tu perds ton temps ici.');
INSERT INTO public.sidebarQuote VALUES (14, 'La proposition 3 va vous surprendre !');
INSERT INTO public.sidebarQuote VALUES (15, 'Chuck Norris approuve ce site.');
INSERT INTO public.sidebarQuote VALUES (16, 'Psst, alt + 128 = Ç, pour écrire ‘Ça va?’ proprement.');
INSERT INTO public.sidebarQuote VALUES (17, 'Yo.');
INSERT INTO public.sidebarQuote VALUES (18, 'Error. Quote not found.');
INSERT INTO public.sidebarQuote VALUES (19, 'Error 314 ? Tant ‘Pi’.');
INSERT INTO public.sidebarQuote VALUES (20, 'Vous savez… J’ai pas vraiment d’amis…');
INSERT INTO public.sidebarQuote VALUES (21, 'Tu trouves ton bonheur ?');
INSERT INTO public.sidebarQuote VALUES (22, 'srevne’l à etxet nu eril sias ut siam seiunne’t uT');
INSERT INTO public.sidebarQuote VALUES (23, '15 3 3 21 16 1 20 9 15 14');
INSERT INTO public.sidebarQuote VALUES (24, '53 27 65 6e 6e 75 79 65 72');
INSERT INTO public.sidebarQuote VALUES (25, '01010011 00100111 01100101 01101101 01101101 01100101 01110010 01100100 01100101 01110010');
INSERT INTO public.sidebarQuote VALUES (26, 'Les Coccinellidae, en français coccinellidés, sont une famille d’insectes de l’ordre des coléoptères, appelés aussi coccinelles, ou encore familièrement ou régionalement bêtes à bon Dieu ou pernettes. Ce taxon monophylétique regroupe environ 6 000 espèces réparties dans le monde entier.');
INSERT INTO public.sidebarQuote VALUES (27, 'Not on my watch.');
INSERT INTO public.sidebarQuote VALUES (28, 'Boit de l’eau.');
INSERT INTO public.sidebarQuote VALUES (29, 'Bomb has been planted.');
INSERT INTO public.sidebarQuote VALUES (30, 'Je vais mettre mon front dans ton back');
INSERT INTO public.sidebarQuote VALUES (31, 'T’as rien à dire ? Alors ta gueule !');
INSERT INTO public.sidebarQuote VALUES (32, 'Tu sais pas ? Alors ta gueule !');
INSERT INTO public.sidebarQuote VALUES (33, 'Eh ! Ta gueule !');
INSERT INTO public.sidebarQuote VALUES (34, 'Just Monika.');
INSERT INTO public.sidebarQuote VALUES (35, 'Ah qu’est-ce qu’on est serré, au fond de cette boîte.');
INSERT INTO public.sidebarQuote VALUES (36, 'Nous nous excusons au nom de toute l’équipe pour le potentiel contenu choquant… En fait non, on s’en fou !');
INSERT INTO public.sidebarQuote VALUES (37, 'Cordialement, la direction !');
INSERT INTO public.sidebarQuote VALUES (38, 'Par pur hasard, ce serai pas l’heure d’aller se coucher ?');
INSERT INTO public.sidebarQuote VALUES (39, 'Je crois que ta mère t’appelle pour manger.');
INSERT INTO public.sidebarQuote VALUES (40, 'Toujours là ? Tu ferais mieux de retourner bosser !');
INSERT INTO public.sidebarQuote VALUES (41, 'Le gâteau est-il vraiment un mensonge ?');
INSERT INTO public.sidebarQuote VALUES (42, 'Ça manque de tolérance tout ça… Et tu sais qui était pas très tolérant ?.. Hitler.');
INSERT INTO public.sidebarQuote VALUES (43, 'Être heureux comme un goldfish dans l’info.');
INSERT INTO public.sidebarQuote VALUES (44, 'Pourquoi ? Hmm… Je vais y réfléchir.');
INSERT INTO public.sidebarQuote VALUES (45, 'Vous savez, je ne pense pas qu’il y ait de bonne ou de mauvaise situation...');
INSERT INTO public.sidebarQuote VALUES (46, 'Eat. Randomize. Sleep. Repeat.');
INSERT INTO public.sidebarQuote VALUES (47, 'Encore là ? C’est vrai qu’ici, c’est pas si mal.');
INSERT INTO public.sidebarQuote VALUES (48, 'La réussite vient avant le travail… Dans le dictionnaire.');
INSERT INTO public.sidebarQuote VALUES (49, 'Ça parle de foot ?');
INSERT INTO public.sidebarQuote VALUES (50, 'Quoi ? Vous comptiez lire quelque chose de potentiellement intéressant ?');
INSERT INTO public.sidebarQuote VALUES (51, 'La vie n’est que frustration.');
INSERT INTO public.sidebarQuote VALUES (52, 'Arrêtez de vous battez !');
INSERT INTO public.sidebarQuote VALUES (53, '');



--
-- Data for Name: source; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.source VALUES (1, 'journal du net', 'https://www.journaldunet.com/rss/');
INSERT INTO public.source VALUES (2, 'random news', 'https://www.journaldunet.com/retail/rss/');
INSERT INTO public.source VALUES (3, 'le journal du hard', 'https://www.journaldunet.com/media/rss/');
INSERT INTO public.source VALUES (4, 'lanruoj el', 'https://www.journaldunet.com/ebusiness/le-net/fintech/rss/');
INSERT INTO public.source VALUES (5, 'gepludide', 'https://www.journaldunet.com/iot/rss/');


--
-- Data for Name: type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.type VALUES (1, 'image');
INSERT INTO public.type VALUES (2, 'article');


--
-- Name: button button_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buttonQuote
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

ALTER TABLE ONLY public.sidebarQuote
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
