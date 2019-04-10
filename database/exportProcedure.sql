SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

CREATE OR REPLACE PROCEDURE public."testGetRandomItems"()
    LANGUAGE plpgsql
    AS $$
DECLARE
  vCounter integer := 0;
  vCountNull integer := 0;
  vIsNull integer;
  vArrayTest json[];
BEGIN
  LOOP
    EXIT WHEN vCounter = 1000;
    vCounter := vCounter + 1;

    SELECT CASE
      WHEN t::text like '%NULL%' THEN 1
      ELSE 0
      END
    INTO vIsNull
    FROM (SELECT "getRandomItems"()) t;

    IF vIsNull > 0 THEN
      RAISE NOTICE 'NULL Item is present';
      vCountNull := vCountNull + 1;
    END IF;
  END LOOP;
  RAISE NOTICE 'ON 1000 SELECT NULL IS FOUND % TIMES', vCountNull;
END;$$;

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
BEGIN
  FOR vfilter in
    (SELECT fil_id from filtre)
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
  vSourcesId integer[];
  vSourceId integer;
  vItemsId integer[];
  vIndexArray integer;
BEGIN
  SELECT ARRAY(
    SELECT ite_source FROM item
    where (ite_pubdate||'+02') :: timestamp > (NOW() - interval '2 days') :: timestamp
    GROUP BY ite_source
    ORDER BY RANDOM()
    LIMIT 12
  ) INTO vSourcesId;

  RAISE NOTICE '%', vSourcesId;

	FOREACH vSourceId IN ARRAY vSourcesId LOOP

    SELECT ARRAY(
  		SELECT ite_id FROM item
  		WHERE  ite_source=vSourceId
  		AND (ite_pubdate||'+02') :: timestamp > (NOW() - interval '2 days') :: timestamp
    ) INTO vItemsId;

    vIndexArray := floor(random() * array_length(vItemsId, 1)) + 1;

    SELECT row_to_json(t)
    INTO vAItem
    FROM item t
    WHERE ite_id = vItemsId[vIndexArray];

    IF vAItem IS NULL THEN
      RAISE NOTICE '%', vSourceId;
      RAISE NOTICE '%', vItemsId;
      RAISE NOTICE '%', vItemsId[vIndexArray];
    END IF;

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
