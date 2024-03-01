--
-- PostgreSQL database dump
--

-- Dumped from database version 14.3
-- Dumped by pg_dump version 14.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: board_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.board_users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    is_admin boolean DEFAULT false,
    board_id uuid,
    user_id uuid
);


ALTER TABLE public.board_users OWNER TO postgres;

--
-- Name: boards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.boards (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(256) NOT NULL
);


ALTER TABLE public.boards OWNER TO postgres;

--
-- Name: card_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.card_users (
    card_id uuid NOT NULL,
    user_id uuid NOT NULL,
    is_owner boolean
);


ALTER TABLE public.card_users OWNER TO postgres;

--
-- Name: cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cards (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    description text,
    due_date date,
    list_id uuid NOT NULL
);


ALTER TABLE public.cards OWNER TO postgres;

--
-- Name: list; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.list (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name name NOT NULL,
    board_id uuid NOT NULL
);


ALTER TABLE public.list OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(256) NOT NULL,
    email character varying(256) NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: board_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.board_users (id, is_admin, board_id, user_id) FROM stdin;
20f97b00-6941-4a90-a58a-2393f329c730	t	4668fb57-537e-4d7e-b283-1795f3b7f3b1	0c751f42-2e29-4c4b-a930-164d9210e0bb
4b73a15f-69dd-44dd-9d19-b7674e437a0b	t	27c283d8-20ad-4971-bfd8-1354432c9173	0c751f42-2e29-4c4b-a930-164d9210e0bb
9d2862e9-64f5-4bf6-b842-4754f1ba44cd	t	a90179bc-b27b-40c3-b92b-f8b2ebb5ab96	0c751f42-2e29-4c4b-a930-164d9210e0bb
ab59f47f-ce04-4144-82fc-a5247ac8e7d0	t	282e64a6-0474-478e-80c0-cca49a67ef5c	0c751f42-2e29-4c4b-a930-164d9210e0bb
\.


--
-- Data for Name: boards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.boards (id, name) FROM stdin;
4668fb57-537e-4d7e-b283-1795f3b7f3b1	Tablero prueba
27c283d8-20ad-4971-bfd8-1354432c9173	Tablero prueba
a90179bc-b27b-40c3-b92b-f8b2ebb5ab96	Tablero prueba
282e64a6-0474-478e-80c0-cca49a67ef5c	Tablero prueba 2
\.


--
-- Data for Name: card_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.card_users (card_id, user_id, is_owner) FROM stdin;
cac9d70c-3973-421e-9190-31c809159d1d	0c751f42-2e29-4c4b-a930-164d9210e0bb	t
\.


--
-- Data for Name: cards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cards (id, title, description, due_date, list_id) FROM stdin;
cac9d70c-3973-421e-9190-31c809159d1d	Tarjeta para lista	Tarjeta para lista (de prueba)	2024-02-28	9b5d2502-973e-4675-b729-6e75d1242b7a
\.


--
-- Data for Name: list; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.list (id, name, board_id) FROM stdin;
9b5d2502-973e-4675-b729-6e75d1242b7a	Lista prueba	a90179bc-b27b-40c3-b92b-f8b2ebb5ab96
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email) FROM stdin;
0c751f42-2e29-4c4b-a930-164d9210e0bb	Aaron	ortiz_aron@test.com
\.


--
-- Name: list LIST_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list
    ADD CONSTRAINT "LIST_pkey" PRIMARY KEY (id);


--
-- Name: board_users board_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.board_users
    ADD CONSTRAINT board_users_pkey PRIMARY KEY (id);


--
-- Name: boards boards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.boards
    ADD CONSTRAINT boards_pkey PRIMARY KEY (id);


--
-- Name: card_users card_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.card_users
    ADD CONSTRAINT card_users_pkey PRIMARY KEY (card_id, user_id);


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: board_users board_users_boardid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.board_users
    ADD CONSTRAINT board_users_boardid_fkey FOREIGN KEY (board_id) REFERENCES public.boards(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: board_users board_users_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.board_users
    ADD CONSTRAINT board_users_userid_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cards card_list; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT card_list FOREIGN KEY (list_id) REFERENCES public.list(id);


--
-- Name: card_users card_users_card_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.card_users
    ADD CONSTRAINT card_users_card_id FOREIGN KEY (card_id) REFERENCES public.cards(id);


--
-- Name: card_users card_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.card_users
    ADD CONSTRAINT card_users_user_id FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: list list_board; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list
    ADD CONSTRAINT list_board FOREIGN KEY (board_id) REFERENCES public.boards(id);


--
-- PostgreSQL database dump complete
--

