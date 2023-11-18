--
-- PostgreSQL database dump
--

-- Dumped from database version 15.5
-- Dumped by pg_dump version 16.1

-- Started on 2023-11-17 19:56:16

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

--
-- TOC entry 881 (class 1247 OID 16525)
-- Name: generacion_disp; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.generacion_disp AS character varying(10)
	CONSTRAINT generacion_disp_check CHECK (((VALUE)::text = ANY ((ARRAY['Gen1'::character varying, 'Gen2'::character varying, 'Gen3'::character varying, 'Gen4'::character varying, 'Gen5'::character varying])::text[])));


ALTER DOMAIN public.generacion_disp OWNER TO postgres;

--
-- TOC entry 874 (class 1247 OID 16485)
-- Name: genero_musical; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.genero_musical AS character varying(50)
	CONSTRAINT genero_musical_check CHECK (((VALUE)::text = ANY ((ARRAY['Rock'::character varying, 'Pop'::character varying, 'Jazz'::character varying, 'Cl sica'::character varying, 'Electr¢nica'::character varying, 'Reggae'::character varying, 'Hip Hop'::character varying, 'Blues'::character varying, 'Country'::character varying, 'Folk'::character varying])::text[])));


ALTER DOMAIN public.genero_musical OWNER TO postgres;

--
-- TOC entry 895 (class 1247 OID 16555)
-- Name: tematica_app; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.tematica_app AS character varying(50)
	CONSTRAINT tematica_app_check CHECK (((VALUE)::text = ANY ((ARRAY['cocina'::character varying, 'lectura'::character varying, 'juegos'::character varying, 'educacion'::character varying, 'salud'::character varying, 'deporte'::character varying, 'musica'::character varying, 'noticias'::character varying])::text[])));


ALTER DOMAIN public.tematica_app OWNER TO postgres;

--
-- TOC entry 888 (class 1247 OID 16541)
-- Name: tipo_proveedor; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.tipo_proveedor AS character varying(20)
	CONSTRAINT tipo_proveedor_check CHECK (((VALUE)::text = ANY ((ARRAY['desarrollador'::character varying, 'empresa'::character varying])::text[])));


ALTER DOMAIN public.tipo_proveedor OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 16599)
-- Name: actualizar_duracion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_duracion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.duracion := NEW.fecha_fin - NEW.fecha_inicio;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.actualizar_duracion() OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 16695)
-- Name: actualizar_puntuacion_producto(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_puntuacion_producto() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    puntuacion_promedio FLOAT;
BEGIN
    -- Calcular la puntuaci¢n promedio para el producto
    SELECT AVG(rating) INTO puntuacion_promedio
    FROM compras
    WHERE id_producto = NEW.id_producto AND rating IS NOT NULL;

    -- Actualizar la puntuaci¢n del producto
    UPDATE producto
    SET puntuacion = puntuacion_promedio
    WHERE id_producto = NEW.id_producto;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.actualizar_puntuacion_producto() OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 16713)
-- Name: fn_crear_promocion_usuario(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_crear_promocion_usuario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_compras INT;
BEGIN
    -- Contar el total de compras realizadas por el usuario antes de esta compra
    SELECT COUNT(*)
    INTO total_compras
    FROM compras
    WHERE id_usuario = NEW.id_usuario AND fecha_compra < NEW.fecha_compra;

    -- Verificar si el usuario ha comprado 3 veces antes de esta compra
    IF total_compras = 3 THEN
        -- Insertar una nueva promoci¢n con un descuento del 30%
        INSERT INTO promocion (descuento, fecha_inicio, fecha_fin, duracion)
        VALUES (30, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 month', 30);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_crear_promocion_usuario() OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 16690)
-- Name: fn_promocion_compras_usuario(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_promocion_compras_usuario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    cantidad_compras INT;
BEGIN
    -- Contar el n£mero de compras realizadas por el usuario
    SELECT COUNT(*)
    INTO cantidad_compras
    FROM compras
    WHERE id_usuario = NEW.id_usuario;

    -- Verificar si el usuario ha comprado m s de 3 productos
    IF cantidad_compras > 3 THEN
        -- Insertar una nueva promoci¢n
        -- Ajusta los valores seg£n tu estructura de tabla y necesidades
        INSERT INTO promocion (descuento, fecha_inicio, fecha_fin, duracion)
        VALUES (30, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 month', 30);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_promocion_compras_usuario() OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 16697)
-- Name: validar_pais_promocion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validar_pais_promocion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    pais_usuario VARCHAR(50);
BEGIN
    -- Si no hay promoci¢n asociada a la compra, no es necesario validar el pa¡s
    IF NEW.id_promo IS NULL THEN
        RETURN NEW;
    END IF;

    -- Obtener el pa¡s del usuario
    SELECT pais INTO pais_usuario
    FROM usuario
    WHERE id_usuario = NEW.id_usuario;

    -- Verificar si el pa¡s del usuario coincide con los pa¡ses de la promoci¢n aplicada
    IF NOT EXISTS (
        SELECT 1
        FROM paises
        WHERE id_promocion = NEW.id_promo AND nombre_pais = pais_usuario
    ) THEN
        RAISE EXCEPTION 'La promoci¢n no es v lida en el pa¡s del usuario.';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.validar_pais_promocion() OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 16692)
-- Name: verificar_compatibilidad_ios(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verificar_compatibilidad_ios() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    version_dispositivo VARCHAR(15);
    version_requerida_app VARCHAR(15);
    es_aplicacion BOOLEAN;
BEGIN
    -- Verificar si el id_producto corresponde a una aplicaci¢n
    SELECT EXISTS(SELECT 1 FROM aplicacion WHERE id_aplicacion = NEW.id_producto)
    INTO es_aplicacion;

    -- Si es una aplicaci¢n, entonces realizar la comprobaci¢n de la versi¢n de iOS
    IF es_aplicacion THEN
        -- Obtener la versi¢n iOS requerida por la aplicaci¢n
        SELECT version_ios INTO version_requerida_app
        FROM aplicacion
        WHERE id_aplicacion = NEW.id_producto;

        -- Verificar si la versi¢n del dispositivo es compatible con la aplicaci¢n
        IF version_dispositivo < version_requerida_app THEN
            RAISE EXCEPTION 'La versi¢n del iOS del dispositivo no es compatible con la aplicaci¢n.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.verificar_compatibilidad_ios() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 223 (class 1259 OID 16558)
-- Name: aplicacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aplicacion (
    "tama¤o_mb" integer NOT NULL,
    version character varying(50) NOT NULL,
    nombre character varying(50) NOT NULL,
    version_ios character varying(10) NOT NULL,
    tematica public.tematica_app,
    id_proveedor integer,
    id_aplicacion integer NOT NULL,
    descripcion character varying(50) NOT NULL,
    CONSTRAINT "aplicacion_tama¤o_mb_check" CHECK (("tama¤o_mb" > 0))
);


ALTER TABLE public.aplicacion OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16461)
-- Name: artista; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.artista (
    id_artista integer NOT NULL,
    nombre_casa_disquera character varying(100) NOT NULL,
    fecha_inicio date DEFAULT CURRENT_DATE NOT NULL,
    fecha_fin date,
    nom_artistico character varying(100) NOT NULL,
    CONSTRAINT artista_check CHECK (((fecha_fin IS NULL) OR (fecha_fin >= fecha_inicio)))
);


ALTER TABLE public.artista OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16460)
-- Name: artista_id_artista_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.artista_id_artista_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.artista_id_artista_seq OWNER TO postgres;

--
-- TOC entry 3500 (class 0 OID 0)
-- Dependencies: 215
-- Name: artista_id_artista_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.artista_id_artista_seq OWNED BY public.artista.id_artista;


--
-- TOC entry 219 (class 1259 OID 16504)
-- Name: cancion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cancion (
    id_cancion integer NOT NULL,
    id_artista integer NOT NULL,
    genero public.genero_musical NOT NULL,
    nom_disco character varying(50) NOT NULL,
    duracion integer NOT NULL,
    fecha_lanz date DEFAULT CURRENT_DATE NOT NULL,
    nomb_cancion character varying(50) NOT NULL,
    un_vendidas integer NOT NULL,
    CONSTRAINT cancion_duracion_check CHECK ((duracion > 0)),
    CONSTRAINT cancion_un_vendidas_check CHECK ((un_vendidas >= 0))
);


ALTER TABLE public.cancion OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 16455)
-- Name: casa_disquera; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.casa_disquera (
    nombre character varying(100) NOT NULL,
    direccion character varying(255) NOT NULL
);


ALTER TABLE public.casa_disquera OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16621)
-- Name: compras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras (
    id_compra integer NOT NULL,
    id_producto integer NOT NULL,
    id_promo integer,
    id_usuario integer NOT NULL,
    fecha_compra date NOT NULL,
    rating integer,
    monto numeric NOT NULL,
    CONSTRAINT compras_rating_check CHECK (((rating >= 1) AND (rating <= 10)))
);


ALTER TABLE public.compras OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16620)
-- Name: compras_id_compra_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.compras_id_compra_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.compras_id_compra_seq OWNER TO postgres;

--
-- TOC entry 3501 (class 0 OID 0)
-- Dependencies: 230
-- Name: compras_id_compra_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.compras_id_compra_seq OWNED BY public.compras.id_compra;


--
-- TOC entry 226 (class 1259 OID 16590)
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    correo character varying(50) NOT NULL,
    nombre character varying(50) NOT NULL,
    apellido character varying(50) NOT NULL,
    num_tdc character varying(16) NOT NULL,
    fecha_venc date NOT NULL,
    cod_vvt character varying(5) NOT NULL,
    direccion character varying(255) NOT NULL,
    pais character varying(50),
    CONSTRAINT usuario_cod_vvt_check CHECK (((cod_vvt)::text ~ '^\d+$'::text)),
    CONSTRAINT usuario_correo_check CHECK (((correo)::text ~ '^.+@.+\..+$'::text)),
    CONSTRAINT usuario_num_tdc_check CHECK (((num_tdc)::text ~ '^\d+$'::text))
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 17003)
-- Name: consulta2; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.consulta2 AS
 SELECT u.num_tdc,
    count(c.id_compra) AS cantidad_compras
   FROM (public.usuario u
     JOIN public.compras c ON ((u.id_usuario = c.id_usuario)))
  WHERE ((u.fecha_venc >= CURRENT_DATE) AND (u.fecha_venc <= (CURRENT_DATE + '3 mons'::interval)))
  GROUP BY u.num_tdc;


ALTER VIEW public.consulta2 OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 17018)
-- Name: consulta3; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.consulta3 AS
 SELECT DISTINCT u.id_usuario,
    u.nombre,
    u.apellido
   FROM public.usuario u
  WHERE ((EXISTS ( SELECT 1
           FROM (public.compras c
             JOIN public.aplicacion a ON ((c.id_producto = a.id_aplicacion)))
          WHERE ((c.id_usuario = u.id_usuario) AND ((a.tematica)::text = 'cocina'::text)))) AND (EXISTS ( SELECT 1
           FROM (public.compras c
             JOIN public.cancion can ON ((c.id_producto = can.id_cancion)))
          WHERE ((c.id_usuario = u.id_usuario) AND ((can.genero)::text = 'Electr¢nica'::text)))));


ALTER VIEW public.consulta3 OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16527)
-- Name: dispositivo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dispositivo (
    id_dispositivo integer NOT NULL,
    capacidad integer,
    generacion public.generacion_disp,
    version_ios character varying(15) NOT NULL,
    modelo character varying(50) NOT NULL,
    CONSTRAINT dispositivo_capacidad_check CHECK ((capacidad > 0))
);


ALTER TABLE public.dispositivo OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16475)
-- Name: producto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.producto (
    id_producto integer NOT NULL,
    puntuacion integer DEFAULT 0,
    costo integer NOT NULL,
    CONSTRAINT producto_costo_check CHECK ((costo > 0)),
    CONSTRAINT producto_puntuacion_check CHECK (((puntuacion >= 0) AND (puntuacion <= 5)))
);


ALTER TABLE public.producto OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 17023)
-- Name: consulta4; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.consulta4 AS
 SELECT a.nombre
   FROM (public.aplicacion a
     JOIN public.producto p ON ((a.id_aplicacion = p.id_producto)))
  WHERE (((a.version_ios)::text <= ( SELECT max((dispositivo.version_ios)::text) AS max
           FROM public.dispositivo)) AND (p.puntuacion > 4));


ALTER VIEW public.consulta4 OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 17038)
-- Name: consulta5; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.consulta5 AS
 SELECT cd.nombre AS nombre_disquera,
    max((sub.cancion_mas_vendida)::text) AS cancion_mas_vendida,
    max(sub.max_unidades_vendidas) AS max_unidades_vendidas
   FROM (public.casa_disquera cd
     JOIN ( SELECT a.nombre_casa_disquera,
            c.nomb_cancion AS cancion_mas_vendida,
            max(c.un_vendidas) AS max_unidades_vendidas
           FROM (public.artista a
             JOIN public.cancion c ON ((a.id_artista = c.id_artista)))
          GROUP BY a.nombre_casa_disquera, c.nomb_cancion) sub ON (((cd.nombre)::text = (sub.nombre_casa_disquera)::text)))
  GROUP BY cd.nombre
 HAVING (count(DISTINCT sub.cancion_mas_vendida) > 1)
  ORDER BY (max(sub.max_unidades_vendidas)) DESC;


ALTER VIEW public.consulta5 OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16544)
-- Name: proveedor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proveedor (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    correo character varying(50) NOT NULL,
    direccion character varying(255) NOT NULL,
    fecha_afiliacion date DEFAULT CURRENT_DATE,
    tipo_proveedor public.tipo_proveedor NOT NULL,
    CONSTRAINT proveedor_correo_check CHECK (((correo)::text ~ '^.+@.+\..+$'::text))
);


ALTER TABLE public.proveedor OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16998)
-- Name: consutla1; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.consutla1 AS
 SELECT p.nombre,
    count(*) AS cantidad_aplicaciones
   FROM (public.proveedor p
     JOIN public.aplicacion a ON ((p.id = a.id_proveedor)))
  GROUP BY p.nombre
  ORDER BY (count(*)) DESC
 LIMIT 1;


ALTER VIEW public.consutla1 OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16579)
-- Name: dispositivo_com; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dispositivo_com (
    dispositivo character varying(50) NOT NULL,
    id_aplicacion integer NOT NULL
);


ALTER TABLE public.dispositivo_com OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16610)
-- Name: paises; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paises (
    nombre_pais character varying(50) NOT NULL,
    id_promocion integer
);


ALTER TABLE public.paises OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16474)
-- Name: producto_id_producto_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.producto_id_producto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.producto_id_producto_seq OWNER TO postgres;

--
-- TOC entry 3502 (class 0 OID 0)
-- Dependencies: 217
-- Name: producto_id_producto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.producto_id_producto_seq OWNED BY public.producto.id_producto;


--
-- TOC entry 228 (class 1259 OID 16601)
-- Name: promocion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promocion (
    id_promocion integer NOT NULL,
    descuento integer NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date NOT NULL,
    duracion integer,
    CONSTRAINT check_descuento_valido CHECK (((descuento >= 0) AND (descuento <= 100))),
    CONSTRAINT promocion_check CHECK ((fecha_fin > fecha_inicio)),
    CONSTRAINT promocion_descuento_check CHECK ((descuento > 0))
);


ALTER TABLE public.promocion OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16600)
-- Name: promocion_id_promocion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.promocion_id_promocion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.promocion_id_promocion_seq OWNER TO postgres;

--
-- TOC entry 3503 (class 0 OID 0)
-- Dependencies: 227
-- Name: promocion_id_promocion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.promocion_id_promocion_seq OWNED BY public.promocion.id_promocion;


--
-- TOC entry 221 (class 1259 OID 16543)
-- Name: proveedor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.proveedor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.proveedor_id_seq OWNER TO postgres;

--
-- TOC entry 3504 (class 0 OID 0)
-- Dependencies: 221
-- Name: proveedor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proveedor_id_seq OWNED BY public.proveedor.id;


--
-- TOC entry 225 (class 1259 OID 16589)
-- Name: usuario_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_id_usuario_seq OWNER TO postgres;

--
-- TOC entry 3505 (class 0 OID 0)
-- Dependencies: 225
-- Name: usuario_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;


--
-- TOC entry 3264 (class 2604 OID 16464)
-- Name: artista id_artista; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artista ALTER COLUMN id_artista SET DEFAULT nextval('public.artista_id_artista_seq'::regclass);


--
-- TOC entry 3273 (class 2604 OID 16624)
-- Name: compras id_compra; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras ALTER COLUMN id_compra SET DEFAULT nextval('public.compras_id_compra_seq'::regclass);


--
-- TOC entry 3266 (class 2604 OID 16667)
-- Name: producto id_producto; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto ALTER COLUMN id_producto SET DEFAULT nextval('public.producto_id_producto_seq'::regclass);


--
-- TOC entry 3272 (class 2604 OID 16604)
-- Name: promocion id_promocion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promocion ALTER COLUMN id_promocion SET DEFAULT nextval('public.promocion_id_promocion_seq'::regclass);


--
-- TOC entry 3269 (class 2604 OID 16547)
-- Name: proveedor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor ALTER COLUMN id SET DEFAULT nextval('public.proveedor_id_seq'::regclass);


--
-- TOC entry 3271 (class 2604 OID 16593)
-- Name: usuario id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);


--
-- TOC entry 3486 (class 0 OID 16558)
-- Dependencies: 223
-- Data for Name: aplicacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.aplicacion ("tama¤o_mb", version, nombre, version_ios, tematica, id_proveedor, id_aplicacion, descripcion) FROM stdin;
150	1.0	App Cocina	10	cocina	1	1	App de Recetas
200	1.1	App Lectura	11	lectura	2	2	App de Libros y Novelas
100	2.0	App Juegos	12	juegos	3	3	Juegos para todas las edades
250	1.5	App Educacion	13	educacion	4	4	Educaci¢n y Aprendizaje
300	3.0	App Salud	14	salud	5	5	Salud y Bienestar
120	1.2	App Deporte	15	deporte	6	6	Deportes y Actividades
180	4.0	App Musica	16	musica	7	7	M£sica y Audio
130	3.5	App Noticias	17	noticias	8	8	Noticias y Revistas
90	2.2	App Fotograf¡a	18	lectura	9	9	Fotograf¡a y Edici¢n
80	1.8	App Viajes	19	educacion	10	10	Viajes y Gu¡as Locales
60	2.0	App Cocina Avanzada	iOS 16	cocina	11	11	Recetas avanzadas para chefs
85	1.3	App Juegos Arcade	iOS 16	juegos	12	12	Juegos arcade cl sicos y modernos
110	2.5	App Aprendizaje Idiomas	iOS 16	educacion	11	13	Aprende idiomas de manera divertida y eficaz
95	1.4	App Fitness Pro	iOS 16	salud	12	14	Rutinas de ejercicios para todos los niveles
\.


--
-- TOC entry 3479 (class 0 OID 16461)
-- Dependencies: 216
-- Data for Name: artista; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.artista (id_artista, nombre_casa_disquera, fecha_inicio, fecha_fin, nom_artistico) FROM stdin;
1	Disquera A	2023-01-01	\N	Artista Uno
2	Disquera B	2023-02-01	\N	Artista Dos
3	Disquera C	2023-03-01	\N	Artista Tres
4	Disquera D	2023-04-01	\N	Artista Cuatro
5	Disquera E	2023-05-01	\N	Artista Cinco
6	Disquera F	2023-06-01	\N	Artista Seis
7	Disquera G	2023-07-01	\N	Artista Siete
8	Disquera H	2023-08-01	\N	Artista Ocho
9	Disquera I	2023-09-01	\N	Artista Nueve
10	Disquera J	2023-10-01	\N	Artista Diez
11	Melod¡as Modernas	2023-11-17	\N	Artista Innovador 1
12	Melod¡as Modernas	2023-11-17	\N	Artista Innovador 2
13	Ritmos del Siglo	2023-11-17	\N	Artista del Siglo 1
14	Ritmos del Siglo	2023-11-17	\N	Artista del Siglo 2
15	Sinfon¡as Urbanas	2023-11-17	\N	Artista Urbano 1
16	Sinfon¡as Urbanas	2023-11-17	\N	Artista Urbano 2
17	Ecos Ancestrales	2023-11-17	\N	Artista Tradicional 1
18	Ecos Ancestrales	2023-11-17	\N	Artista Tradicional 2
19	Acordes Contempor neos	2023-11-17	\N	Artista Contempor neo 1
20	Acordes Contempor neos	2023-11-17	\N	Artista Contempor neo 2
21	Disquera K	2023-11-17	\N	Artista K1
22	Disquera K	2023-11-17	\N	Artista K2
23	Disquera K	2023-11-17	\N	Artista K3
24	Disquera K	2023-11-17	\N	Artista K4
25	Disquera L	2023-11-17	\N	Artista L1
26	Disquera L	2023-11-17	\N	Artista L2
27	Disquera L	2023-11-17	\N	Artista L3
28	Disquera M	2023-11-17	\N	Artista M1
29	Disquera M	2023-11-17	\N	Artista M2
30	Disquera M	2023-11-17	\N	Artista M3
31	Disquera M	2023-11-17	\N	Artista M4
32	Disquera M	2023-11-17	\N	Artista M5
33	Nueva Disquera	2023-11-17	\N	Artista Nuevo 1
34	Nueva Disquera	2023-11-17	\N	Artista Nuevo 2
35	Nueva Disquera	2023-11-17	\N	Artista Nuevo 3
36	Nueva Disquera	2023-11-17	\N	Artista Nuevo 4
\.


--
-- TOC entry 3482 (class 0 OID 16504)
-- Dependencies: 219
-- Data for Name: cancion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cancion (id_cancion, id_artista, genero, nom_disco, duracion, fecha_lanz, nomb_cancion, un_vendidas) FROM stdin;
1	1	Pop	µlbum A	180	2023-01-01	Canci¢n A1	1000
2	2	Rock	µlbum B	210	2023-02-02	Canci¢n B1	800
3	3	Jazz	µlbum C	200	2023-03-03	Canci¢n C1	600
4	4	Blues	µlbum D	240	2023-04-04	Canci¢n D1	500
5	5	Electr¢nica	µlbum E	300	2023-05-05	Canci¢n E1	700
6	6	Reggae	µlbum F	220	2023-06-06	Canci¢n F1	550
7	7	Country	µlbum G	260	2023-07-07	Canci¢n G1	450
9	9	Hip Hop	µlbum I	230	2023-09-09	Canci¢n I1	650
10	10	Folk	µlbum J	270	2023-10-10	Canci¢n J1	400
8	8	Rock	µlbum H	280	2023-08-08	Canci¢n H1	500
11	1	Electr¢nica	Disco Electr¢nico	200	2023-11-17	Canci¢n Electr¢nica 1	500
33	11	Electr¢nica	µlbum Electr¢nico 1	210	2023-11-17	Electro Hit 1	1300
31	12	Reggae	µlbum Reggae 1	220	2023-11-17	Reggae Groove 1	1150
32	13	Country	µlbum Country 1	205	2023-11-17	Country Road 1	950
34	14	Hip Hop	µlbum Hip Hop 1	215	2023-11-17	Hip Hop Beat 1	870
104	14	Pop	µlbum Pop	190	2023-11-17	Canci¢n Pop 1	1200
106	15	Rock	µlbum Rock	220	2023-11-17	Canci¢n Rock 1	1050
107	21	Rock	Nuevo µlbum Rock	240	2023-11-17	Rock Hit Disquera K	1200
108	28	Pop	Nuevo µlbum Pop	230	2023-11-17	Pop Hit Disquera M	1100
109	33	Jazz	Nuevo µlbum Jazz	220	2023-11-17	Jazz Hit Nueva Disquera	1000
\.


--
-- TOC entry 3477 (class 0 OID 16455)
-- Dependencies: 214
-- Data for Name: casa_disquera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.casa_disquera (nombre, direccion) FROM stdin;
Disquera B	Avenida 456, Ciudad B
Disquera C	V¡a 789, Ciudad C
Disquera D	Pasaje 101, Ciudad D
Disquera E	Boulevard 202, Ciudad E
Disquera F	Carretera 303, Ciudad F
Disquera G	Ruta 404, Ciudad G
Disquera H	Camino 505, Ciudad H
Disquera I	Paseo 606, Ciudad I
Disquera J	Sendero 707, Ciudad J
Disquera A	Calle 123, Ciudad A
Melod¡as Modernas	Avenida del Progreso 101
Ritmos del Siglo	Calle de la Armon¡a 202
Sinfon¡as Urbanas	Boulevard del Jazz 303
Ecos Ancestrales	Pasaje del Folklore 404
Acordes Contempor neos	Ruta de la Innovaci¢n 505
Disquera K	Calle 111, Ciudad K
Disquera L	Avenida 222, Ciudad L
Disquera M	V¡a 333, Ciudad M
Nueva Disquera	Calle Nueva, Ciudad Nueva
\.


--
-- TOC entry 3494 (class 0 OID 16621)
-- Dependencies: 231
-- Data for Name: compras; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras (id_compra, id_producto, id_promo, id_usuario, fecha_compra, rating, monto) FROM stdin;
14	1	\N	1	2023-11-16	5	100.0
16	2	1	1	2023-11-16	4	80.0
17	3	\N	3	2023-11-16	4	200.0
18	4	\N	4	2023-11-16	3	50.0
19	3	\N	1	2023-11-16	4	150.0
20	4	\N	1	2023-11-16	3	200.0
21	5	\N	1	2023-11-16	5	250.0
22	6	\N	1	2023-11-16	4	300.0
23	3	\N	1	2023-11-16	4	150.0
24	4	\N	1	2023-11-16	3	200.0
25	5	\N	1	2023-11-16	5	250.0
26	6	\N	1	2023-11-16	4	300.0
27	3	\N	1	2023-11-16	4	150.0
28	4	\N	1	2023-11-16	3	200.0
29	5	\N	1	2023-11-16	5	250.0
30	6	\N	1	2023-11-16	4	300.0
31	1	\N	1	2023-11-16	5	100.0
32	2	\N	2	2023-11-16	4	150.0
33	3	\N	3	2023-11-16	3	200.0
34	4	1	1	2023-11-16	4	85.0
35	5	2	2	2023-11-16	5	75.0
37	7	\N	1	2023-11-16	5	120.0
38	8	\N	1	2023-11-16	4	110.0
39	9	\N	1	2023-11-16	5	130.0
40	10	\N	1	2023-11-16	4	140.0
41	11	\N	1	2023-11-17	5	120.0
42	12	\N	2	2023-11-17	4	150.0
43	11	\N	3	2023-11-17	3	90.0
44	12	\N	4	2023-11-17	4	110.0
47	1	\N	1	2023-11-17	4	150.0
51	1	\N	1	2023-11-17	4	20.0
52	5	\N	1	2023-11-17	5	15.0
53	11	\N	1	2023-11-17	4	150.0
54	33	\N	1	2023-11-17	4	150.0
55	104	\N	3	2023-11-17	5	100.0
56	106	\N	3	2023-11-17	4	60.0
\.


--
-- TOC entry 3483 (class 0 OID 16527)
-- Dependencies: 220
-- Data for Name: dispositivo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dispositivo (id_dispositivo, capacidad, generacion, version_ios, modelo) FROM stdin;
11	64	Gen1	iOS 10	Modelo A
12	128	Gen2	iOS 11	Modelo B
13	256	Gen3	iOS 12	Modelo C
14	512	Gen4	iOS 13	Modelo D
15	32	Gen1	iOS 14	Modelo E
16	64	Gen2	iOS 15	Modelo F
17	128	Gen3	iOS 16	Modelo G
18	256	Gen4	iOS 17	Modelo H
19	512	Gen1	iOS 18	Modelo I
20	32	Gen2	iOS 19	Modelo J
\.


--
-- TOC entry 3487 (class 0 OID 16579)
-- Dependencies: 224
-- Data for Name: dispositivo_com; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dispositivo_com (dispositivo, id_aplicacion) FROM stdin;
11	1
12	2
13	3
14	4
15	5
16	6
17	7
18	8
19	9
20	10
\.


--
-- TOC entry 3492 (class 0 OID 16610)
-- Dependencies: 229
-- Data for Name: paises; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.paises (nombre_pais, id_promocion) FROM stdin;
Espa¤a	1
M‚xico	2
Argentina	3
Colombia	4
Per£	5
Chile	6
Ecuador	7
Guatemala	8
Cuba	9
Bolivia	10
Italia	11
Alemania	11
\.


--
-- TOC entry 3481 (class 0 OID 16475)
-- Dependencies: 218
-- Data for Name: producto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.producto (id_producto, puntuacion, costo) FROM stdin;
13	4	250
14	3	200
15	3	150
16	4	400
17	5	500
18	4	450
19	3	180
20	5	550
21	4	10
22	5	15
23	3	5
24	2	3
25	4	12
26	3	8
27	5	20
28	4	11
29	2	4
30	3	7
6	4	70
2	4	80
3	4	90
4	3	50
7	5	60
8	4	110
9	5	30
10	4	150
12	4	350
1	4	100
5	5	120
31	3	75
32	5	120
34	2	30
35	5	200
11	4	300
33	4	90
104	5	60
106	4	70
107	4	300
108	4	300
109	4	300
\.


--
-- TOC entry 3491 (class 0 OID 16601)
-- Dependencies: 228
-- Data for Name: promocion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promocion (id_promocion, descuento, fecha_inicio, fecha_fin, duracion) FROM stdin;
1	10	2023-01-01	2023-01-31	30
2	15	2023-02-01	2023-02-28	27
3	20	2023-03-01	2023-03-31	30
4	25	2023-04-01	2023-04-30	29
5	30	2023-05-01	2023-05-31	30
6	35	2023-06-01	2023-06-30	29
7	40	2023-07-01	2023-07-31	30
8	45	2023-08-01	2023-08-31	30
9	50	2023-09-01	2023-09-30	29
10	55	2023-10-01	2023-10-31	30
11	30	2023-11-16	2023-12-16	30
12	30	2023-11-16	2023-12-16	30
13	30	2023-11-16	2023-12-16	30
14	30	2023-11-16	2023-12-16	30
15	30	2023-11-16	2023-12-16	30
16	30	2023-11-16	2023-12-16	30
17	30	2023-11-16	2023-12-16	30
18	30	2023-11-16	2023-12-16	30
19	30	2023-11-16	2023-12-16	30
20	30	2023-11-16	2023-12-16	30
21	30	2023-11-16	2023-12-16	30
22	30	2023-11-16	2023-12-16	30
23	30	2023-11-16	2023-12-16	30
24	30	2023-11-16	2023-12-16	30
25	30	2023-11-16	2023-12-16	30
26	30	2023-11-16	2023-12-16	30
27	30	2023-11-16	2023-12-16	30
28	30	2023-11-16	2023-12-16	30
29	30	2023-11-16	2023-12-16	30
30	30	2023-11-16	2023-12-16	30
31	30	2023-11-17	2023-12-17	30
32	30	2023-11-17	2023-12-17	30
33	30	2023-11-17	2023-12-17	30
34	30	2023-11-17	2023-12-17	30
35	30	2023-11-17	2023-12-17	30
36	30	2023-11-17	2023-12-17	30
37	30	2023-11-17	2023-12-17	30
38	30	2023-11-17	2023-12-17	30
\.


--
-- TOC entry 3485 (class 0 OID 16544)
-- Dependencies: 222
-- Data for Name: proveedor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.proveedor (id, nombre, correo, direccion, fecha_afiliacion, tipo_proveedor) FROM stdin;
1	Proveedor 1	correo1@proveedor.com	Direcci¢n 1	2023-11-16	desarrollador
2	Proveedor 2	correo2@proveedor.com	Direcci¢n 2	2023-11-16	desarrollador
3	Proveedor 3	correo3@proveedor.com	Direcci¢n 3	2023-11-16	desarrollador
4	Proveedor 4	correo4@proveedor.com	Direcci¢n 4	2023-11-16	desarrollador
5	Proveedor 5	correo5@proveedor.com	Direcci¢n 5	2023-11-16	desarrollador
6	Empresa A	correo6@empresa.com	Direcci¢n 6	2023-11-16	empresa
7	Empresa B	correo7@empresa.com	Direcci¢n 7	2023-11-16	empresa
8	Empresa C	correo8@empresa.com	Direcci¢n 8	2023-11-16	empresa
9	Empresa D	correo9@empresa.com	Direcci¢n 9	2023-11-16	empresa
10	Empresa E	correo10@empresa.com	Direcci¢n 10	2023-11-16	empresa
11	Desarrollador X	contacto@desarrolladorx.com	Direcci¢n X	2023-11-17	desarrollador
12	Empresa Y	info@empresay.com	Direcci¢n Y	2023-11-17	empresa
\.


--
-- TOC entry 3489 (class 0 OID 16590)
-- Dependencies: 226
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario (id_usuario, correo, nombre, apellido, num_tdc, fecha_venc, cod_vvt, direccion, pais) FROM stdin;
3	luis.gomez@example.com	Luis	Gomez	9999000011112222	2025-03-01	345	789 Callejon Inventado	Colombia
4	ana.ruiz@example.com	Ana	Ruiz	1234123412341234	2025-04-01	456	1010 Via Secundaria	Argentina
5	david.martinez@example.com	David	Martinez	4321432143214321	2025-05-01	567	1111 Paseo Ficticio	Chile
6	laura.jimenez@example.com	Laura	Jimenez	6789678967896789	2025-06-01	678	1212 Calle Sintetica	Per£
7	carlos.hernandez@example.com	Carlos	Hernandez	2222333344445555	2025-07-01	789	1313 Avenida Noexistente	Venezuela
8	sara.garcia@example.com	Sara	Garcia	1111222233334444	2025-08-01	890	1414 Calle Ilusoria	Ecuador
9	miguel.torres@example.com	Miguel	Torres	3333444455556666	2025-09-01	901	1515 Avenida Falsa	Bolivia
10	carmen.rodriguez@example.com	Carmen	Rodriguez	7777888899990000	2025-10-01	012	1616 Sendero Inexistente	Paraguay
1	juan.perez@example.com	Juan	Perez	1111222233334444	2023-12-17	123	123 Calle Ficticia	Espa¤a
2	maria.lopez@example.com	Maria	Lopez	5555666677778888	2024-01-17	234	456 Avenida Imaginaria	M‚xico
\.


--
-- TOC entry 3506 (class 0 OID 0)
-- Dependencies: 215
-- Name: artista_id_artista_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.artista_id_artista_seq', 36, true);


--
-- TOC entry 3507 (class 0 OID 0)
-- Dependencies: 230
-- Name: compras_id_compra_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.compras_id_compra_seq', 56, true);


--
-- TOC entry 3508 (class 0 OID 0)
-- Dependencies: 217
-- Name: producto_id_producto_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.producto_id_producto_seq', 20, true);


--
-- TOC entry 3509 (class 0 OID 0)
-- Dependencies: 227
-- Name: promocion_id_promocion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.promocion_id_promocion_seq', 38, true);


--
-- TOC entry 3510 (class 0 OID 0)
-- Dependencies: 221
-- Name: proveedor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.proveedor_id_seq', 10, true);


--
-- TOC entry 3511 (class 0 OID 0)
-- Dependencies: 225
-- Name: usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 10, true);


--
-- TOC entry 3302 (class 2606 OID 16573)
-- Name: aplicacion aplicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT aplicacion_pkey PRIMARY KEY (id_aplicacion);


--
-- TOC entry 3292 (class 2606 OID 16468)
-- Name: artista artista_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artista
    ADD CONSTRAINT artista_pkey PRIMARY KEY (id_artista);


--
-- TOC entry 3296 (class 2606 OID 16513)
-- Name: cancion cancion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT cancion_pkey PRIMARY KEY (id_cancion);


--
-- TOC entry 3290 (class 2606 OID 16459)
-- Name: casa_disquera casa_disquera_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.casa_disquera
    ADD CONSTRAINT casa_disquera_pkey PRIMARY KEY (nombre);


--
-- TOC entry 3312 (class 2606 OID 16629)
-- Name: compras compras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_pkey PRIMARY KEY (id_compra, fecha_compra);


--
-- TOC entry 3304 (class 2606 OID 16583)
-- Name: dispositivo_com dispositivo_com_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dispositivo_com
    ADD CONSTRAINT dispositivo_com_pkey PRIMARY KEY (dispositivo);


--
-- TOC entry 3298 (class 2606 OID 16534)
-- Name: dispositivo dispositivo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dispositivo
    ADD CONSTRAINT dispositivo_pkey PRIMARY KEY (id_dispositivo);


--
-- TOC entry 3310 (class 2606 OID 16614)
-- Name: paises paises_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paises
    ADD CONSTRAINT paises_pkey PRIMARY KEY (nombre_pais);


--
-- TOC entry 3294 (class 2606 OID 16669)
-- Name: producto producto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_pkey PRIMARY KEY (id_producto);


--
-- TOC entry 3308 (class 2606 OID 16608)
-- Name: promocion promocion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promocion
    ADD CONSTRAINT promocion_pkey PRIMARY KEY (id_promocion);


--
-- TOC entry 3300 (class 2606 OID 16553)
-- Name: proveedor proveedor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id);


--
-- TOC entry 3306 (class 2606 OID 16598)
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 3325 (class 2620 OID 16696)
-- Name: compras actualizar_puntuacion_after_compra; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER actualizar_puntuacion_after_compra AFTER INSERT OR UPDATE OF rating ON public.compras FOR EACH ROW WHEN ((new.rating IS NOT NULL)) EXECUTE FUNCTION public.actualizar_puntuacion_producto();


--
-- TOC entry 3324 (class 2620 OID 16609)
-- Name: promocion calcular_duracion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER calcular_duracion BEFORE INSERT OR UPDATE ON public.promocion FOR EACH ROW EXECUTE FUNCTION public.actualizar_duracion();


--
-- TOC entry 3326 (class 2620 OID 16714)
-- Name: compras tr_crear_promocion_despues_compra; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_crear_promocion_despues_compra AFTER INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.fn_crear_promocion_usuario();


--
-- TOC entry 3327 (class 2620 OID 16691)
-- Name: compras tr_promocion_compras; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_promocion_compras AFTER INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.fn_promocion_compras_usuario();


--
-- TOC entry 3328 (class 2620 OID 16698)
-- Name: compras validar_pais_promocion_before_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER validar_pais_promocion_before_insert BEFORE INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.validar_pais_promocion();


--
-- TOC entry 3329 (class 2620 OID 16693)
-- Name: compras verificar_compatibilidad_ios_before_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER verificar_compatibilidad_ios_before_insert BEFORE INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.verificar_compatibilidad_ios();


--
-- TOC entry 3317 (class 2606 OID 16680)
-- Name: aplicacion fk_aplicacion_producto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT fk_aplicacion_producto FOREIGN KEY (id_aplicacion) REFERENCES public.producto(id_producto);


--
-- TOC entry 3318 (class 2606 OID 16567)
-- Name: aplicacion fk_aplicacion_proveedor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT fk_aplicacion_proveedor FOREIGN KEY (id_proveedor) REFERENCES public.proveedor(id);


--
-- TOC entry 3313 (class 2606 OID 16469)
-- Name: artista fk_artista_casa_disquera; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artista
    ADD CONSTRAINT fk_artista_casa_disquera FOREIGN KEY (nombre_casa_disquera) REFERENCES public.casa_disquera(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3314 (class 2606 OID 16519)
-- Name: cancion fk_cancion_artista; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT fk_cancion_artista FOREIGN KEY (id_artista) REFERENCES public.artista(id_artista);


--
-- TOC entry 3315 (class 2606 OID 16670)
-- Name: cancion fk_cancion_producto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT fk_cancion_producto FOREIGN KEY (id_cancion) REFERENCES public.producto(id_producto);


--
-- TOC entry 3321 (class 2606 OID 16685)
-- Name: compras fk_compras_producto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_producto FOREIGN KEY (id_producto) REFERENCES public.producto(id_producto);


--
-- TOC entry 3322 (class 2606 OID 16635)
-- Name: compras fk_compras_promo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_promo FOREIGN KEY (id_promo) REFERENCES public.promocion(id_promocion);


--
-- TOC entry 3323 (class 2606 OID 16640)
-- Name: compras fk_compras_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 3319 (class 2606 OID 16584)
-- Name: dispositivo_com fk_dispositivo_com_aplicacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dispositivo_com
    ADD CONSTRAINT fk_dispositivo_com_aplicacion FOREIGN KEY (id_aplicacion) REFERENCES public.aplicacion(id_aplicacion);


--
-- TOC entry 3316 (class 2606 OID 16675)
-- Name: dispositivo fk_dispositivo_producto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dispositivo
    ADD CONSTRAINT fk_dispositivo_producto FOREIGN KEY (id_dispositivo) REFERENCES public.producto(id_producto);


--
-- TOC entry 3320 (class 2606 OID 16615)
-- Name: paises fk_key_promocion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paises
    ADD CONSTRAINT fk_key_promocion FOREIGN KEY (id_promocion) REFERENCES public.promocion(id_promocion);


-- Completed on 2023-11-17 19:56:17

--
-- PostgreSQL database dump complete
--

