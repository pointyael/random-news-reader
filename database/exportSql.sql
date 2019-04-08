--
-- PostgreSQL database dump
--

-- Dumped from database version 11.2
-- Dumped by pg_dump version 11.2

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
-- Name: deleteOldItemsProc(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE OR REPLACE PROCEDURE public."deleteOldItemsProc"()
    LANGUAGE plpgsql
    AS $$
DECLARE
  vAItem json;
BEGIN
  FOR vAItem in
    SELECT row_to_json(i) FROM item i
  LOOP
    IF
      (vAItem->>'ite_pubdate'||'+01') :: timestamp
      < (NOW() - interval '2 days') :: timestamp
    THEN
      DELETE FROM item WHERE ite_id = to_number(vAItem->>'ite_id', '99G999D9S');
    END IF;
  END LOOP;
END;$$;


ALTER PROCEDURE public."deleteOldItemsProc"() OWNER TO postgres;


CREATE OR REPLACE FUNCTION public."getRandomFilterWords"() RETURNS json[]
    LANGUAGE plpgsql
    AS $$
DECLARE
  vfilter integer;
  vJson json[];
  vAWord json;
  --cur CURSOR FOR SELECT * from filtrelocalise;
BEGIN
-- TRY WITH ONLY FR
  FOR vfilter in
    (SELECT fil_id from filtre where fil_id < 6)
  LOOP
    SELECT row_to_json(fl) into vAWord from filtrelocalise fl
    join filtre on fil_id=fll_filtre
    WHERE fll_filtre = vfilter
    ORDER BY RANDOM() LIMIT 1;

    vJson := array_append(vJson, vAWord);
  END LOOP;
  RETURN vJson;
END;$$;

-- ALTER FUNCTION public."getRandomFilterWords"() OWNER TO postgres;

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
      SELECT ite_source FROM item
      GROUP BY ite_source
			ORDER BY RANDOM()
			LIMIT 12
		) LOOP

      SELECT row_to_json(t)
      INTO vAItem
      FROM
      (
        SELECT *
        FROM item
        -- To reinsert into the Query
        -- when we will have reliable relationship
        -- between tables
        --JOIN language ON ite_language=lan_id
        --JOIN type ON ite_type=typ_id
        --JOIN category ON ite_category=cat_id
        WHERE ite_source=vSourceId
        -- AND
        --   (ite_pubdate||'+01') :: timestamp > (NOW() - interval '2 days') :: timestamp
        ORDER BY RANDOM()
        LIMIT 1
      ) t ;

    vJson := array_append(vJson, vAItem);
  END LOOP;

  RETURN vJson;

END;$$;


ALTER FUNCTION public."getRandomItems"() OWNER TO postgres;

--
-- Name: getRandomItemsNotLike(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION public."getRandomItemsNotLike"(pkeyword text[]) RETURNS json[]
    LANGUAGE plpgsql
    AS $$DECLARE

  vAItem json;
  vJson json[];
  vSourceId int;
  vSources int[];
BEGIN

  SELECT "sourcesNotLike"(pKeyWord) INTO vSources;
  FOREACH vSourceId IN ARRAY vSources LOOP

      SELECT "itemNotLike"(vSourceId, pKeyWord) INTO vAItem;
      vJson := array_append(vJson, vAItem);

  END LOOP;
  RETURN vJson;

END;$$;


ALTER FUNCTION public."getRandomItemsNotLike"(pkeyword text[]) OWNER TO postgres;

--
-- Name: insertNewItems(json, json); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE OR REPLACE PROCEDURE public."insertNewItems"(pSource json, pItems json)
    LANGUAGE plpgsql
    AS $$
    DECLARE
      vAItem json;
      vNewId integer;
      vLangId integer;
      vCategoryId integer;
      vSourceId integer;
      vCountItem integer;
    BEGIN

        FOR vAItem in
          SELECT * FROM json_array_elements(pItems)
        LOOP

            SELECT COUNT(*) INTO vCountItem FROM item
            WHERE ite_title like vAItem->>'title';

            IF vCountItem = 0 THEN

              SELECT lan_id INTO vLangId
              FROM language
              WHERE lower(lan_code)::text LIKE (vAItem->>'language'::text) || '%'
              OR lower(lan_lib)::text LIKE (vAItem->>'language'::text) || '%'
              LIMIT 1;

              IF vLangId IS NULL THEN
                vLangId := 13; --English language default
              END IF;

              SELECT cat_id INTO vCategoryId
              FROM category
              WHERE cat_lib=vAItem->>'category';

              INSERT INTO public.item
               (
                 ite_title,
                 ite_description,
                 ite_enclosure,
                 ite_type,
                 ite_link,
                 ite_pubdate,
                 ite_language,
                 ite_category,
                 ite_source
               )
              VALUES
                (
                  vAItem->>'title',
                  vAItem->>'description',
                  vAItem->>'enclosure',
                  to_number(vAItem->>'type', '99G999D9S'),
                  vAItem->>'link',
                  to_timestamp(vAItem->>'pubDate', 'YYYY-MM-DD HH24:MI:SS'),
                  vLangId,
                  vCategoryId,
                  to_number(pSource->>'id', '99G999D9S')
                );
            END IF;
        END LOOP;
END;$$;


ALTER PROCEDURE public."insertNewItems"(pSource json, pItems json) OWNER TO postgres;

--
-- Name: itemNotLike(integer, text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION public."itemNotLike"(psource integer, pclause text[]) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
  vAItem json;
  vWhereClause text;
  vSelectClause text;
  vItemChosen item%ROWTYPE;
BEGIN

  vSelectClause := 'SELECT * FROM item WHERE ite_source=' || pSource;

  FOREACH vWhereClause IN ARRAY pClause
  LOOP
      vSelectClause :=
      vSelectClause
      || ' AND ( lower(ite_title) NOT LIKE ''%' || lower(vWhereClause) || '%'''
      || ' AND lower(ite_description) NOT LIKE ''%' || lower(vWhereClause) || '%'''
      || ' AND lower(ite_link) NOT LIKE ''%' || lower(vWhereClause) || '%'')';
  END LOOP;

  vSelectClause :=
    vSelectClause
    || ' ORDER BY RANDOM() LIMIT 1';

    EXECUTE vSelectClause INTO vItemChosen;

    SELECT row_to_json(vItemChosen)
    INTO vAItem;


    RETURN vAItem;
END;
$$;


ALTER FUNCTION public."itemNotLike"(psource integer, pclause text[]) OWNER TO postgres;

--
-- Name: sourcesNotLike(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION public."sourcesNotLike"(pclause text[]) RETURNS integer[]
    LANGUAGE plpgsql
    AS $$
DECLARE
  vSourceIds int[];
  vWhereClause text;
  vSelectClause text;
BEGIN

  vSelectClause :=
    'SELECT array_agg(sou_id::integer) FROM source'
    || ' WHERE sou_id IN ( SELECT ite_source FROM item GROUP BY ite_source ) ';

  FOREACH vWhereClause IN ARRAY pClause
  LOOP
      vSelectClause :=
      vSelectClause
      || ' AND (lower(sou_title) NOT LIKE ''%' || lower(vWhereClause) || '%'''
      || ' AND lower(sou_link) NOT LIKE ''%' || lower(vWhereClause) || '%'')';
  END LOOP;

  vSelectClause :=
    vSelectClause
    || ' ORDER BY RANDOM() LIMIT 12';

    EXECUTE vSelectClause INTO vSourceIds;

    RETURN vSourceIds;
END;
$$;


ALTER FUNCTION public."sourcesNotLike"(pclause text[]) OWNER TO postgres;

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
-- Name: filtre; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.filtre (
    fil_id integer PRIMARY KEY,
    fil_mot text
);


ALTER TABLE public.filtre OWNER TO postgres;

--
-- Name: filtrelocalise; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.filtrelocalise (
    fll_filtre integer NOT NULL,
    fll_language integer NOT NULL,
    fll_localise text
);


ALTER TABLE public.filtrelocalise OWNER TO postgres;

--
-- Name: item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item (
    ite_id SERIAL,
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
    mot_id SERIAL PRIMARY KEY,
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
    sou_id SERIAL,
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
-- Data for Name: filtre; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.filtre VALUES (1, 'pornographie');
INSERT INTO public.filtre VALUES (2, 'sport');
INSERT INTO public.filtre VALUES (3, 'politique');
INSERT INTO public.filtre VALUES (4, 'people');
INSERT INTO public.filtre VALUES (5, 'chat');
INSERT INTO public.filtre VALUES (6, 'musique');


--
-- Data for Name: filtrelocalise; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.filtrelocalise VALUES (1, 1, 'pornografie');
INSERT INTO public.filtrelocalise VALUES (1, 2, 'pornografi');
INSERT INTO public.filtrelocalise VALUES (1, 3, 'pornoa');
INSERT INTO public.filtrelocalise VALUES (1, 4, 'порна');
INSERT INTO public.filtrelocalise VALUES (1, 5, 'порнография');
INSERT INTO public.filtrelocalise VALUES (1, 6, 'pornografia');
INSERT INTO public.filtrelocalise VALUES (1, 7, '色情');
INSERT INTO public.filtrelocalise VALUES (1, 8, '色情');
INSERT INTO public.filtrelocalise VALUES (1, 9, 'pornografija');
INSERT INTO public.filtrelocalise VALUES (1, 10, 'pornografie');
INSERT INTO public.filtrelocalise VALUES (1, 11, 'pornografi');
INSERT INTO public.filtrelocalise VALUES (1, 12, 'pornografie');
INSERT INTO public.filtrelocalise VALUES (1, 13, 'pornography');
INSERT INTO public.filtrelocalise VALUES (1, 14, 'pornograafia');
INSERT INTO public.filtrelocalise VALUES (1, 15, 'pornografia');
INSERT INTO public.filtrelocalise VALUES (1, 16, 'pornographie');
INSERT INTO public.filtrelocalise VALUES (1, 17, 'pornografía');
INSERT INTO public.filtrelocalise VALUES (1, 18, 'drabastachd');
INSERT INTO public.filtrelocalise VALUES (1, 19, 'Pornographie');
INSERT INTO public.filtrelocalise VALUES (1, 20, 'πορνογραφία');
INSERT INTO public.filtrelocalise VALUES (1, 21, 'pornography');
INSERT INTO public.filtrelocalise VALUES (1, 22, 'pornográfia');
INSERT INTO public.filtrelocalise VALUES (1, 23, 'klámi');
INSERT INTO public.filtrelocalise VALUES (1, 24, 'pornografi');
INSERT INTO public.filtrelocalise VALUES (1, 25, 'pornagrafaíocht');
INSERT INTO public.filtrelocalise VALUES (1, 26, 'pornografia');
INSERT INTO public.filtrelocalise VALUES (1, 27, 'ポルノ');
INSERT INTO public.filtrelocalise VALUES (1, 28, '포르노');
INSERT INTO public.filtrelocalise VALUES (1, 29, 'порно');
INSERT INTO public.filtrelocalise VALUES (1, 30, 'Porn');
INSERT INTO public.filtrelocalise VALUES (1, 31, 'porno');
INSERT INTO public.filtrelocalise VALUES (1, 32, 'pornô');
INSERT INTO public.filtrelocalise VALUES (1, 33, 'porno');
INSERT INTO public.filtrelocalise VALUES (1, 34, 'порно');
INSERT INTO public.filtrelocalise VALUES (1, 35, 'порнографија');
INSERT INTO public.filtrelocalise VALUES (1, 36, 'pornografie');
INSERT INTO public.filtrelocalise VALUES (1, 37, 'pornografijo');
INSERT INTO public.filtrelocalise VALUES (1, 38, 'pornografía');
INSERT INTO public.filtrelocalise VALUES (1, 39, 'pornografi');
INSERT INTO public.filtrelocalise VALUES (1, 40, 'pornografi');
INSERT INTO public.filtrelocalise VALUES (1, 41, 'порнографія');
INSERT INTO public.filtrelocalise VALUES (2, 1, 'sport');
INSERT INTO public.filtrelocalise VALUES (2, 2, 'sport');
INSERT INTO public.filtrelocalise VALUES (2, 3, 'kirol');
INSERT INTO public.filtrelocalise VALUES (2, 4, 'спартыўны');
INSERT INTO public.filtrelocalise VALUES (2, 5, 'спортен');
INSERT INTO public.filtrelocalise VALUES (2, 6, 'esports');
INSERT INTO public.filtrelocalise VALUES (2, 7, '体育');
INSERT INTO public.filtrelocalise VALUES (2, 8, '體育');
INSERT INTO public.filtrelocalise VALUES (2, 9, 'sportski');
INSERT INTO public.filtrelocalise VALUES (2, 10, 'sportovní');
INSERT INTO public.filtrelocalise VALUES (2, 11, 'sport');
INSERT INTO public.filtrelocalise VALUES (2, 12, 'Sport');
INSERT INTO public.filtrelocalise VALUES (2, 13, 'Sport');
INSERT INTO public.filtrelocalise VALUES (2, 14, 'Sport');
INSERT INTO public.filtrelocalise VALUES (2, 15, 'urheilu');
INSERT INTO public.filtrelocalise VALUES (2, 16, 'sportif');
INSERT INTO public.filtrelocalise VALUES (2, 17, 'Deportes');
INSERT INTO public.filtrelocalise VALUES (2, 18, 'spòrs');
INSERT INTO public.filtrelocalise VALUES (2, 19, 'Sport');
INSERT INTO public.filtrelocalise VALUES (2, 20, 'αθλητισμός');
INSERT INTO public.filtrelocalise VALUES (2, 21, 'haʻuki');
INSERT INTO public.filtrelocalise VALUES (2, 22, 'sport');
INSERT INTO public.filtrelocalise VALUES (2, 23, 'íþróttir');
INSERT INTO public.filtrelocalise VALUES (2, 24, 'Olahraga');
INSERT INTO public.filtrelocalise VALUES (2, 25, 'spórt');
INSERT INTO public.filtrelocalise VALUES (2, 26, 'sport');
INSERT INTO public.filtrelocalise VALUES (2, 27, 'スポーツ');
INSERT INTO public.filtrelocalise VALUES (2, 28, '스포츠');
INSERT INTO public.filtrelocalise VALUES (2, 29, 'Спорт');
INSERT INTO public.filtrelocalise VALUES (2, 30, 'sport');
INSERT INTO public.filtrelocalise VALUES (2, 31, 'sport');
INSERT INTO public.filtrelocalise VALUES (2, 32, 'esporte');
INSERT INTO public.filtrelocalise VALUES (2, 33, 'sportiv');
INSERT INTO public.filtrelocalise VALUES (2, 34, 'спортивный');
INSERT INTO public.filtrelocalise VALUES (2, 35, 'спортски');
INSERT INTO public.filtrelocalise VALUES (2, 36, 'športové');
INSERT INTO public.filtrelocalise VALUES (2, 37, 'šport');
INSERT INTO public.filtrelocalise VALUES (2, 38, 'deportes');
INSERT INTO public.filtrelocalise VALUES (2, 39, 'sports');
INSERT INTO public.filtrelocalise VALUES (2, 40, 'spor');
INSERT INTO public.filtrelocalise VALUES (2, 41, 'спортивний');
INSERT INTO public.filtrelocalise VALUES (3, 1, 'beleid');
INSERT INTO public.filtrelocalise VALUES (3, 2, 'politikë');
INSERT INTO public.filtrelocalise VALUES (3, 3, 'politika');
INSERT INTO public.filtrelocalise VALUES (3, 4, 'палітыка');
INSERT INTO public.filtrelocalise VALUES (3, 5, 'политика');
INSERT INTO public.filtrelocalise VALUES (3, 6, 'política');
INSERT INTO public.filtrelocalise VALUES (3, 7, '政策');
INSERT INTO public.filtrelocalise VALUES (3, 8, '政策');
INSERT INTO public.filtrelocalise VALUES (3, 9, 'politika');
INSERT INTO public.filtrelocalise VALUES (3, 10, 'politika');
INSERT INTO public.filtrelocalise VALUES (3, 11, 'politik');
INSERT INTO public.filtrelocalise VALUES (3, 12, 'politiek');
INSERT INTO public.filtrelocalise VALUES (3, 13, 'politics');
INSERT INTO public.filtrelocalise VALUES (3, 14, 'poliitika');
INSERT INTO public.filtrelocalise VALUES (3, 15, 'politiikka');
INSERT INTO public.filtrelocalise VALUES (3, 16, 'politique');
INSERT INTO public.filtrelocalise VALUES (3, 17, 'política');
INSERT INTO public.filtrelocalise VALUES (3, 18, 'poileasaidh');
INSERT INTO public.filtrelocalise VALUES (3, 19, 'Politik');
INSERT INTO public.filtrelocalise VALUES (3, 20, 'πολιτική');
INSERT INTO public.filtrelocalise VALUES (3, 21, 'ʻikepili');
INSERT INTO public.filtrelocalise VALUES (3, 22, 'információ');
INSERT INTO public.filtrelocalise VALUES (3, 23, 'upplýsingar');
INSERT INTO public.filtrelocalise VALUES (3, 24, 'informasi');
INSERT INTO public.filtrelocalise VALUES (3, 25, 'faisnéis');
INSERT INTO public.filtrelocalise VALUES (3, 26, 'informazioni');
INSERT INTO public.filtrelocalise VALUES (3, 27, '情報');
INSERT INTO public.filtrelocalise VALUES (3, 28, '정보');
INSERT INTO public.filtrelocalise VALUES (3, 29, 'информации');
INSERT INTO public.filtrelocalise VALUES (3, 30, 'informasjon');
INSERT INTO public.filtrelocalise VALUES (3, 31, 'informacja');
INSERT INTO public.filtrelocalise VALUES (3, 32, 'informação');
INSERT INTO public.filtrelocalise VALUES (3, 33, 'informații');
INSERT INTO public.filtrelocalise VALUES (3, 34, 'информация');
INSERT INTO public.filtrelocalise VALUES (3, 35, 'информације');
INSERT INTO public.filtrelocalise VALUES (3, 36, 'informácie');
INSERT INTO public.filtrelocalise VALUES (3, 37, 'informacije');
INSERT INTO public.filtrelocalise VALUES (3, 38, 'información');
INSERT INTO public.filtrelocalise VALUES (3, 39, 'Information');
INSERT INTO public.filtrelocalise VALUES (3, 40, 'bilgi');
INSERT INTO public.filtrelocalise VALUES (3, 41, 'інформація');
INSERT INTO public.filtrelocalise VALUES (4, 1, 'mense');
INSERT INTO public.filtrelocalise VALUES (4, 2, 'njerëz');
INSERT INTO public.filtrelocalise VALUES (4, 3, 'jende');
INSERT INTO public.filtrelocalise VALUES (4, 4, 'людзі');
INSERT INTO public.filtrelocalise VALUES (4, 5, 'хора');
INSERT INTO public.filtrelocalise VALUES (4, 6, 'persones');
INSERT INTO public.filtrelocalise VALUES (4, 7, '人');
INSERT INTO public.filtrelocalise VALUES (4, 8, '人');
INSERT INTO public.filtrelocalise VALUES (4, 9, 'ljudi');
INSERT INTO public.filtrelocalise VALUES (4, 10, 'lidé');
INSERT INTO public.filtrelocalise VALUES (4, 11, 'mennesker');
INSERT INTO public.filtrelocalise VALUES (4, 12, 'mensen');
INSERT INTO public.filtrelocalise VALUES (4, 13, 'people');
INSERT INTO public.filtrelocalise VALUES (4, 14, 'inimesed');
INSERT INTO public.filtrelocalise VALUES (4, 15, 'ihmiset');
INSERT INTO public.filtrelocalise VALUES (4, 16, 'personnes');
INSERT INTO public.filtrelocalise VALUES (4, 17, 'persoas');
INSERT INTO public.filtrelocalise VALUES (4, 18, 'daoine');
INSERT INTO public.filtrelocalise VALUES (4, 19, 'Leute');
INSERT INTO public.filtrelocalise VALUES (4, 20, 'άνθρωποι');
INSERT INTO public.filtrelocalise VALUES (4, 21, 'kanaka');
INSERT INTO public.filtrelocalise VALUES (4, 22, 'emberek');
INSERT INTO public.filtrelocalise VALUES (4, 23, 'fólk');
INSERT INTO public.filtrelocalise VALUES (4, 24, 'orang-orang');
INSERT INTO public.filtrelocalise VALUES (4, 25, 'daoine');
INSERT INTO public.filtrelocalise VALUES (4, 26, 'persone');
INSERT INTO public.filtrelocalise VALUES (4, 27, '人々');
INSERT INTO public.filtrelocalise VALUES (4, 28, '사람들');
INSERT INTO public.filtrelocalise VALUES (4, 29, 'луѓе');
INSERT INTO public.filtrelocalise VALUES (4, 30, 'mennesker');
INSERT INTO public.filtrelocalise VALUES (4, 31, 'ludzie');
INSERT INTO public.filtrelocalise VALUES (4, 32, 'pessoas');
INSERT INTO public.filtrelocalise VALUES (4, 33, 'oameni');
INSERT INTO public.filtrelocalise VALUES (4, 34, 'люди');
INSERT INTO public.filtrelocalise VALUES (4, 35, 'људи');
INSERT INTO public.filtrelocalise VALUES (4, 36, 'ľudia');
INSERT INTO public.filtrelocalise VALUES (4, 37, 'ljudje');
INSERT INTO public.filtrelocalise VALUES (4, 38, 'personas');
INSERT INTO public.filtrelocalise VALUES (4, 39, 'människor');
INSERT INTO public.filtrelocalise VALUES (4, 40, 'insanlar');
INSERT INTO public.filtrelocalise VALUES (4, 41, 'люди');
INSERT INTO public.filtrelocalise VALUES (5, 1, 'kat');
INSERT INTO public.filtrelocalise VALUES (5, 2, 'mace');
INSERT INTO public.filtrelocalise VALUES (5, 3, 'katu');
INSERT INTO public.filtrelocalise VALUES (5, 4, 'кот');
INSERT INTO public.filtrelocalise VALUES (5, 5, 'котка');
INSERT INTO public.filtrelocalise VALUES (5, 6, 'gat');
INSERT INTO public.filtrelocalise VALUES (5, 7, '猫');
INSERT INTO public.filtrelocalise VALUES (5, 8, '貓');
INSERT INTO public.filtrelocalise VALUES (5, 9, 'mačka');
INSERT INTO public.filtrelocalise VALUES (5, 10, 'kočka');
INSERT INTO public.filtrelocalise VALUES (5, 11, 'kat');
INSERT INTO public.filtrelocalise VALUES (5, 12, 'kat');
INSERT INTO public.filtrelocalise VALUES (5, 13, 'cat');
INSERT INTO public.filtrelocalise VALUES (5, 14, 'kass');
INSERT INTO public.filtrelocalise VALUES (5, 15, 'kissa');
INSERT INTO public.filtrelocalise VALUES (5, 16, 'chat');
INSERT INTO public.filtrelocalise VALUES (5, 17, 'gato');
INSERT INTO public.filtrelocalise VALUES (5, 18, 'cat');
INSERT INTO public.filtrelocalise VALUES (5, 19, 'Katze');
INSERT INTO public.filtrelocalise VALUES (5, 20, 'γάτα');
INSERT INTO public.filtrelocalise VALUES (5, 21, 'popoki');
INSERT INTO public.filtrelocalise VALUES (5, 22, 'macska');
INSERT INTO public.filtrelocalise VALUES (5, 23, 'köttur');
INSERT INTO public.filtrelocalise VALUES (5, 24, 'kucing');
INSERT INTO public.filtrelocalise VALUES (5, 25, 'cat');
INSERT INTO public.filtrelocalise VALUES (5, 26, 'gatto');
INSERT INTO public.filtrelocalise VALUES (5, 27, '猫');
INSERT INTO public.filtrelocalise VALUES (5, 28, '고양이');
INSERT INTO public.filtrelocalise VALUES (5, 29, 'мачка');
INSERT INTO public.filtrelocalise VALUES (5, 30, 'katt');
INSERT INTO public.filtrelocalise VALUES (5, 31, 'kot');
INSERT INTO public.filtrelocalise VALUES (5, 32, 'gato');
INSERT INTO public.filtrelocalise VALUES (5, 33, 'pisică');
INSERT INTO public.filtrelocalise VALUES (5, 34, 'кот');
INSERT INTO public.filtrelocalise VALUES (5, 35, 'мачка');
INSERT INTO public.filtrelocalise VALUES (5, 36, 'mačka');
INSERT INTO public.filtrelocalise VALUES (5, 37, 'mačka');
INSERT INTO public.filtrelocalise VALUES (5, 38, 'gato');
INSERT INTO public.filtrelocalise VALUES (5, 39, 'cat');
INSERT INTO public.filtrelocalise VALUES (5, 40, 'kedi');
INSERT INTO public.filtrelocalise VALUES (5, 41, 'кіт');



--
-- Data for Name: item; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES('Ligue du LOL : après Vincent Glad et David Doucet, les noms des membres traqués',' ',1,'https://www.linternaute.com/actualite/societe/1778944-ligue-du-lol-qui-sont-les-membres-de-ce-collectif/',' 2019-03-17 12:00:00',1, 2, 2,'https://img-4.linternaute.com/otyopbeAmfp4dUghjRoHOPUEDMk=/1280x/smart/7f048ada8ba743bf9b41f3d563d8e144/ccmcms-linternaute/11039619.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES('Elections européennes 2019 : date, sondage, candidats... Tout savoir',' ',1,'https://www.linternaute.com/actualite/politique/1447387-elections-europeennes-2019-lr-se-lance-actus-sondage-date-candidats/',' 2019-03-17 12:00:00',1, 2, 2,'https://img-4.linternaute.com/1BE9uNqpiXtXg6QcyGJi0u0eMd0=/1280x/smart/073f007710bd4ceb979a0d0d5b0d7b75/ccmcms-linternaute/11025865.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES('Cadeau de Noël pour ado : des idées (vraiment bonnes) pour les jeunes',' ',1,'https://www.linternaute.com/actualite/societe/1421509-cadeau-de-noel-pour-ado-des-idees-vraiment-bonnes-pour-les-jeunes/',' 2019-03-17 12:00:00',1, 2, 3,'https://img-4.linternaute.com/bPJQKBREqHgjb1TKzh2Wl9rSsxc=/1280x/smart/bf243105ad2246858335c755e15e74b4/ccmcms-linternaute/10995837.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES('De trader à humoriste, qui est vraiment François-Xavier Demaison ?',' ',1,'https://www.linternaute.com/cinema/star-cinema/1779080-de-trader-a-humoriste-qui-est-vraiment-francois-xavier-demaison/',' 2019-03-17 12:00:00',1, 2, 3,'https://img-4.linternaute.com/0GUv7GHkWJWK7xlwOFrWNnvdWeI=/1280x/smart/c1fe9322e287463090f2d4bff14f7843/ccmcms-linternaute/11040005.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES('Crise des gilets jaunes : un acte 14 samedi et dimanche ?',' ',1,'https://www.linternaute.com/actualite/politique/1756762-crise-des-gilets-jaunes-un-acte-14-samedi-et-dimanche/',' 2019-03-17 12:00:00',1, 2, 4,'https://img-4.linternaute.com/wG88tfkgi7DtfC6Ws8q0UzoSv5w=/1280x/smart/8dbbbe5a58ec46b39b6b7c48b3008e45/ccmcms-linternaute/11039753.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES('Renault F1 : la RS19 dévoilée, les photos de la F1 2019',' ',1,'http://www.linternaute.com/auto/magazine/1282102-renault-f1-la-rs19-presentee-les-photos-et-infos-de-la-f1-2019/',' 2019-03-17 12:00:00',1, 2, 4,'https://img-4.linternaute.com/MdjwngjjNK6dZ2AJhMgTtZGC1Ew=/1280x/smart/74aca18397a942bf9a2d2f67b9fbcfc7/ccmcms-linternaute/11040008.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES('La nouvelle F1 de Renault, la RS19, en images',' ',1,'https://www.linternaute.com/auto/magazine/1779190-la-nouvelle-f1-de-renault-la-rs19-en-images/',' 2019-03-17 12:00:00',1, 2, 5,'https://img-4.linternaute.com/8UsOH6avhK_97FfpYArXwgYlcMo=/1280x/smart/51b24fdd78624ad689ff0f264b99b796/ccmcms-linternaute/11039973.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES('Rentrée scolaire 2019 : date, actus, nouveautés et coût',' ',1,'https://www.linternaute.com/actualite/education/1243286-rentree-scolaire-2019-la-date-et-les-actus/',' 2019-03-17 12:00:00',1, 2, 5,'https://img-4.linternaute.com/BTqacoJa-Uk5vG2vzgGa5pLcfRc=/1280x/smart/9ff90738dd83453e941fcd0975fce2e5/ccmcms-linternaute/11039997.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Espagne : début du procès historique des dirigeants indépendantistes catalans',' ',1,'https://www.linternaute.com/actualite/depeches/1779036-espagne-debut-du-proces-historique-des-dirigeants-independantistes-catalans/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/TZLGPxfb0cmQcu7Xvxpf_h8xLHs=/1280x/smart/05d3702bd5da42269b574919a9e97266/ccmcms-linternaute/11039972.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Syrie: poursuite de violents combats dans lultime réduit de lEI',' ',1,'https://www.linternaute.com/actualite/depeches/1779186-syrie-des-centaines-de-civils-fuient-les-combats-dans-l-ultime-reduit-de-l-ei/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/z7v4Xmyi0Tp8K-HUVQz_XojIVno=/1280x/smart/67b930e8e3a047cb8f15bd473a394932/ccmcms-linternaute/11039960.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Venezuela: nouvelle mobilisation pour exiger lentrée de laide, à lappel de lopposition',' ',1,'https://www.linternaute.com/actualite/depeches/1778852-venezuela-guaido-avertit-l-armee-que-bloquer-l-aide-est-un-crime-contre-l-humanite/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/W7Z98q8usJTq8g2VO0LFFjSMiRo=/1280x/smart/7d4db8d31f70499c9edc57fda4591d31/ccmcms-linternaute/11039943.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Etats-Unis: percée au Congrès pour éviter un nouveau shutdown',' ',1,'https://www.linternaute.com/actualite/depeches/1779044-trump-vante-le-mur-a-el-paso-percee-au-congres/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/bNfkElSmdsWuYiAyePRJ48kxvhQ=/1280x/smart/5cfdbae972af417ca2535450fa38fb36/ccmcms-linternaute/11040004.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Expo Toutânkhamon : découvrez les oeuvres en avant-première',' ',1,'https://www.linternaute.com/sortir/guide-des-loisirs/1762890-expo-toutankhamon-decouvrez-les-oeuvres-en-avant-premiere/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/dGKwDLIUeAnpGYsdmfD00bEw5_8=/1280x/smart/da301a3e72ed40e7913b4509661ed3fe/ccmcms-linternaute/11039876.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Condamnations unanimes après le bond des actes antisémites',' ',1,'https://www.linternaute.com/actualite/depeches/1779188-condamnations-unanimes-apres-le-bond-des-actes-antisemites/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/Ak5U4djVQuROKViX81zS_PSNAjk=/1280x/smart/fba1714feca24659a6cc1dfdcc976658/ccmcms-linternaute/11039937.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Mort de Gordon Banks, le gardien qui a écoeuré le roi Pelé',' ',1,'https://www.linternaute.com/actualite/depeches/1389897-orages-17-departements-en-vigilance-orange/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/ZB9QcDN605AbFXtqdeLe8k6BuZI=/1280x/smart/58653c0a0800435eb53cc43dbf389c02/ccmcms-linternaute/11039955.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Des boues rouges de lusine Alteo devant le ministère de lEcologie',' ',1,'https://www.linternaute.com/actualite/depeches/1779046-des-boues-rouges-de-l-usine-alteo-devant-le-ministere-de-l-ecologie/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/WyxKdfuh_zj5rsvf5zUVOxQtdQo=/1280x/smart/5187bcd2e9504ffa8813aac7e36449dd/ccmcms-linternaute/11039874.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Permis de conduire : le permis dès 17 ans, moins cher avec la réforme ?',' ',1,'https://www.linternaute.com/auto/guide-pratique-auto/1409150-permis-de-conduire-sera-t-il-moins-cher-ce-que-la-reforme-prevoit/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/bVakaj3ggK0VRVbY0rEAVIIi6eE=/1280x/smart/bc7185f4aac5442ca0a3a2179567a092/ccmcms-linternaute/11039818.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Classement des lycées 2019 : un premier palmarès déjà établi, les chiffres clés',' ',1,'https://www.linternaute.com/actualite/education/1368870-classement-des-lycees-2019-un-premier-palmares-deja-etabli-les-chiffres-cles/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/coZn1V4GQHlvdOXM3ASADoYOEsk=/1280x/smart/93cf1a71df044cb4bb666375a68fb26c/ccmcms-linternaute/11039870.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Intrusion au ministère de Griveaux par des gilets jaunes: six personnes interpellées',' ',1,'https://www.linternaute.com/actualite/depeches/1779048-intrusion-au-ministere-de-griveaux-par-des-gilets-jaunes-quatre-personnes-interpellees/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/j9z46dWaen_djJ34LbUsj9fMxp4=/1280x/smart/129468a4a64b4c4eb66d48bdefe3bfd3/ccmcms-linternaute/11039863.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Au Théâtre des rêves de Manchester, le PSG espère briser sa malédiction européenne',' ',1,'https://www.linternaute.com/actualite/depeches/1779038-au-theatre-des-reves-de-manchester-le-psg-veut-s-eviter-un-cauchemar-europeen/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/_y8i4vynLQE950FJmzWrTi06CV4=/1280x/smart/7f24a947b3f6453585d57f9c533df1a4/ccmcms-linternaute/11040043.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Musée Grévin 2019 : 30 nouvelles stars en cire ont investi les lieux',' ',1,'https://www.linternaute.com/sortir/guide-des-loisirs/1414839-musee-grevin-2019-30-nouvelles-stars-en-cire-ont-investi-les-lieux/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/Tw1d4JkBRjhkhnS__a-emLTrHoY=/1280x/smart/e9ca957e52e74eaab54da454f481ac29/ccmcms-linternaute/11034168.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Résultat de lEuromillion (FDJ) : le tirage du mardi 12 février 2019, cest 151 millions !',' ',1,'https://www.linternaute.com/actualite/societe/1779182-resultat-de-l-euromillion-fdj-le-tirage-du-mardi-12-fevrier-2019-c-est-151-millions/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/DGdkIHQJGRBvtFlgqeRj5vn_gSM=/1280x/smart/c74056259b3b443481964c5f4d77bef3/ccmcms-linternaute/11039851.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Équinoxe de printemps 2019 : définition, date et fête païenne',' ',1,'https://www.linternaute.com/actualite/societe/1218670-equinoxe-de-printemps-la-meteo-qui-vous-attend-cette-semaine/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/g0d-kv86QpBtO9Kg6c5mwx9v30k=/1280x/smart/ec6fd5e50ab44d5594fc1735413758dd/ccmcms-linternaute/11039835.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Policiers tués à Magnanville en 2016: deux hommes en garde à vue',' ',1,'https://www.linternaute.com/actualite/depeches/1779184-policiers-tues-a-magnanville-en-2016-deux-hommes-en-garde-a-vue/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/IysqHgw3kyqlMvk4Wn4xX6VI1G4=/1280x/smart/fb62bd3742524eb7ba62ab535a211b9a/ccmcms-linternaute/11040001.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Chocolat : le petit-fils de Charlie Chaplin joue avec Omar Sy !',' ',1,'https://www.linternaute.com/television/chocolat-le-petit-fils-de-charlie-chaplin-joue-avec-omar-sy-p3721924/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/g-TDaY5YsapqMfmQAHXlvjZpbOw=/1280x/smart/263b8fd81acd4d0990bd746f3c663fde/ccmcms-linternaute/11039817.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Démission dIsmaël Emelien : pourquoi fait-on le lien avec Benalla ?',' ',1,'https://www.linternaute.com/actualite/personnalites/1779042-emelien-des-liens-avec-l-affaire-benalla/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/7XOpu7k7ODXNVS-jpY8_jIvnMgE=/1280x/smart/e7bd51b7a7654d71a9701e4d76712d4a/ccmcms-linternaute/11039614.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( '12 coups de midi : les indices sur létoile mystérieuse',' ',1,'https://www.linternaute.com/television/12-coups-de-midi-les-indices-sur-l-etoile-mysterieuse-p3119439/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/2zw6bqJLUj0ihCKPKyFyTVWemaY=/1280x/smart/2076d088c0ed451ead0ef19db7e15e0b/ccmcms-linternaute/11039811.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'Journée internationale des droits des femmes 2019 : des citations et son histoire',' ',1,'https://www.linternaute.com/actualite/societe/1272879-journee-internationale-des-droits-des-femmes-2019-des-citations-et-son-histoire/',' 2019-03-17 12:00:00',1, 2, 1,'https://img-4.linternaute.com/qQ9bW8PhqnMCbeGpFTGF7EAIBqI=/1280x/smart/8b7ad3a2f4d6497abe04568071d00457/ccmcms-linternaute/11039807.jpg');
INSERT INTO public.item (ite_title, ite_description, ite_type, ite_link, ite_pubdate, ite_language, ite_category, ite_source, ite_enclosure) VALUES( 'La Saint-Valentin, fashion week des roses dEquateur',' ',1,'https://www.linternaute.com/actualite/depeches/1779118-la-saint-valentin-fashion-week-des-roses-d-equateur/',' 2019-03-11 12:00:00',1, 2, 1,'https://img-4.linternaute.com/IeDRS1K1Pahdkfnnv_lDVGjBykk=/1280x/smart/6a2a17a0553f486ea30654115e85cc1a/ccmcms-linternaute/11039768.jpg');


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
INSERT INTO public.language VALUES (13, 'en', 'English');
INSERT INTO public.language VALUES (14, 'et', 'Estonian');
INSERT INTO public.language VALUES (15, 'fi', 'Finnish');
INSERT INTO public.language VALUES (16, 'fr', 'French');
INSERT INTO public.language VALUES (17, 'gl', 'Galician');
INSERT INTO public.language VALUES (18, 'gd', 'Gaelic');
INSERT INTO public.language VALUES (19, 'de', 'German');
INSERT INTO public.language VALUES (20, 'el', 'Greek');
INSERT INTO public.language VALUES (21, 'haw', 'Hawaiian');
INSERT INTO public.language VALUES (22, 'hu', 'Hungarian');
INSERT INTO public.language VALUES (23, 'is', 'Icelandic');
INSERT INTO public.language VALUES (24, 'in', 'Indonesian');
INSERT INTO public.language VALUES (25, 'ga', 'Irish');
INSERT INTO public.language VALUES (26, 'it', 'Italian');
INSERT INTO public.language VALUES (27, 'ja', 'Japanese');
INSERT INTO public.language VALUES (28, 'ko', 'Korean');
INSERT INTO public.language VALUES (29, 'mk', 'Macedonian');
INSERT INTO public.language VALUES (30, 'no', 'Norwegian');
INSERT INTO public.language VALUES (31, 'pl', 'Polish');
INSERT INTO public.language VALUES (32, 'pt', 'Portuguese');
INSERT INTO public.language VALUES (33, 'ro', 'Romanian');
INSERT INTO public.language VALUES (34, 'ru', 'Russian');
INSERT INTO public.language VALUES (35, 'sr', 'Serbian');
INSERT INTO public.language VALUES (36, 'sk', 'Slovak');
INSERT INTO public.language VALUES (37, 'sl', 'Slovenian');
INSERT INTO public.language VALUES (38, 'es', 'Spanish');
INSERT INTO public.language VALUES (39, 'sv', 'Swedish');
INSERT INTO public.language VALUES (40, 'tr', 'Turkish');
INSERT INTO public.language VALUES (41, 'uk', 'Ukranian');


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

INSERT INTO public.source (sou_title, sou_link) VALUES ('journal du net', 'https://www.journaldunet.com/rss/');
INSERT INTO public.source (sou_title, sou_link) VALUES ('jeuxvideo.com', 'http://www.jeuxvideo.com/rss/rss.xml');
INSERT INTO public.source (sou_title, sou_link) VALUES ('le journal du hard', 'https://www.journaldunet.com/media/rss/');
INSERT INTO public.source (sou_title, sou_link) VALUES ('lanruoj el', 'https://www.journaldunet.com/ebusiness/le-net/fintech/rss/');
INSERT INTO public.source (sou_title, sou_link) VALUES ('L''internaute', 'http://www.linternaute.com/rss/');
INSERT INTO public.source (sou_title, sou_link) VALUES ('MixMag', 'https://mixmag.net/rss.xml');
INSERT INTO public.source (sou_title, sou_link) VALUES ('Le Monde - Unes', 'https://www.lemonde.fr/rss/une.xml');
INSERT INTO public.source (sou_title, sou_link) VALUES ('Mediapart - Chroniques', 'http://www.mediapart.fr/journal/podcast/chronique/rss');
INSERT INTO public.source (sou_title, sou_link) VALUES ('La Dépêche', 'https://www.ladepeche.fr/rss.xml');
INSERT INTO public.source (sou_title, sou_link) VALUES ( 'Les Echos - société et monde', 'https://syndication.lesechos.fr/rss/rss_politique_societe.xml');
INSERT INTO public.source (sou_title, sou_link) VALUES ( 'Les Echos - idées', 'https://syndication.lesechos.fr/rss/rss_idee.xml');
INSERT INTO public.source (sou_title, sou_link) VALUES ( 'Courrier Internationale', 'https://www.courrierinternational.com/feed/all/rss.xml');
INSERT INTO public.source (sou_title, sou_link) VALUES ( 'Huffing Post', 'https://www.huffingtonpost.fr/feeds/index.xml');
INSERT INTO public.source (sou_title, sou_link) VALUES ( 'New York Times - US HomePage', 'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml');
INSERT INTO public.source (sou_title, sou_link) VALUES ( 'Washington Post - Fast Checker', 'http://feeds.washingtonpost.com/rss/rss_fact-checker');
INSERT INTO public.source (sou_title, sou_link) VALUES ( 'Washington Post - WorldViews', 'http://feeds.washingtonpost.com/rss/rss_blogpost');


--
-- Data for Name: type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.type VALUES (1, 'article');
INSERT INTO public.type VALUES (2, 'mp3');


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
