--
-- PostgreSQL database dump
--

-- Dumped from database version 11.2
-- Dumped by pg_dump version 11.2


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
