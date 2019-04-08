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

  vSourceId integer;
  vSources integer[];
BEGIN

  SELECT "sourcesNotLike"(pKeyWord) INTO vSources;
  FOREACH vSourceId IN ARRAY vSources LOOP

      SELECT "itemNotLike"(vSourceId, pKeyWord) INTO vAItem;
      vJson := array_append(vJson, vAItem);

  END LOOP;

  RAISE NOTICE '%', vSources;
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

CREATE OR REPLACE FUNCTION public."itemNotLike"(pSource integer, pclause text[]) RETURNS json
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
  vSourceIds integer[];
  vWhereClause text;
  vSelectClause text;
BEGIN

  vSelectClause :=
    'SELECT ARRAY(SELECT sou_id FROM source'
    || ' WHERE sou_id IN ( SELECT ite_source FROM item GROUP BY ite_source ) ';

  FOREACH vWhereClause IN ARRAY pClause
  LOOP
      vSelectClause :=
      vSelectClause
      || ' AND lower(sou_link) NOT LIKE ''%' || lower(vWhereClause) || '%''';
  END LOOP;

  vSelectClause :=
    vSelectClause
    || ' ORDER BY RANDOM() LIMIT 12)';

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

INSERT INTO public.source (sou_link) VALUES ('https://www.journaldunet.com/rss/');
INSERT INTO public.source (sou_link) VALUES ('http://www.jeuxvideo.com/rss/rss.xml');
INSERT INTO public.source (sou_link) VALUES ('https://www.journaldunet.com/media/rss/');
INSERT INTO public.source (sou_link) VALUES ('https://www.journaldunet.com/ebusiness/le-net/fintech/rss/');
INSERT INTO public.source (sou_link) VALUES ('http://www.linternaute.com/rss/');
INSERT INTO public.source (sou_link) VALUES ('https://mixmag.net/rss.xml');
INSERT INTO public.source (sou_link) VALUES ('https://www.lemonde.fr/rss/une.xml');
INSERT INTO public.source (sou_link) VALUES ('http://www.mediapart.fr/journal/podcast/chronique/rss');
INSERT INTO public.source (sou_link) VALUES ('https://www.ladepeche.fr/rss.xml');
INSERT INTO public.source (sou_link) VALUES ('https://syndication.lesechos.fr/rss/rss_politique_societe.xml');
INSERT INTO public.source (sou_link) VALUES ('https://syndication.lesechos.fr/rss/rss_idee.xml');
INSERT INTO public.source (sou_link) VALUES ('https://www.courrierinternational.com/feed/all/rss.xml');
INSERT INTO public.source (sou_link) VALUES ('https://www.huffingtonpost.fr/feeds/index.xml');
INSERT INTO public.source (sou_link) VALUES ('http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml');
INSERT INTO public.source (sou_link) VALUES ('http://feeds.washingtonpost.com/rss/rss_fact-checker');
INSERT INTO public.source (sou_link) VALUES ('http://feeds.washingtonpost.com/rss/rss_blogpost');


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
