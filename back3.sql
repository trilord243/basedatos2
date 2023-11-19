toc.dat                                                                                             0000600 0004000 0002000 00000107644 14526470135 0014462 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        PGDMP                   
    {            proyecto_fase2    15.5    16.1 _    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false         �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false         �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false         �           1262    16454    proyecto_fase2    DATABASE     �   CREATE DATABASE proyecto_fase2 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Latin America.1252';
    DROP DATABASE proyecto_fase2;
                postgres    false         q           1247    16525    generacion_disp    DOMAIN       CREATE DOMAIN public.generacion_disp AS character varying(10)
	CONSTRAINT generacion_disp_check CHECK (((VALUE)::text = ANY ((ARRAY['Gen1'::character varying, 'Gen2'::character varying, 'Gen3'::character varying, 'Gen4'::character varying, 'Gen5'::character varying])::text[])));
 $   DROP DOMAIN public.generacion_disp;
       public          postgres    false         j           1247    16485    genero_musical    DOMAIN     �  CREATE DOMAIN public.genero_musical AS character varying(50)
	CONSTRAINT genero_musical_check CHECK (((VALUE)::text = ANY ((ARRAY['Rock'::character varying, 'Pop'::character varying, 'Jazz'::character varying, 'Cl sica'::character varying, 'Electr¢nica'::character varying, 'Reggae'::character varying, 'Hip Hop'::character varying, 'Blues'::character varying, 'Country'::character varying, 'Folk'::character varying])::text[])));
 #   DROP DOMAIN public.genero_musical;
       public          postgres    false                    1247    16555    tematica_app    DOMAIN     y  CREATE DOMAIN public.tematica_app AS character varying(50)
	CONSTRAINT tematica_app_check CHECK (((VALUE)::text = ANY ((ARRAY['cocina'::character varying, 'lectura'::character varying, 'juegos'::character varying, 'educacion'::character varying, 'salud'::character varying, 'deporte'::character varying, 'musica'::character varying, 'noticias'::character varying])::text[])));
 !   DROP DOMAIN public.tematica_app;
       public          postgres    false         x           1247    16541    tipo_proveedor    DOMAIN     �   CREATE DOMAIN public.tipo_proveedor AS character varying(20)
	CONSTRAINT tipo_proveedor_check CHECK (((VALUE)::text = ANY ((ARRAY['desarrollador'::character varying, 'empresa'::character varying])::text[])));
 #   DROP DOMAIN public.tipo_proveedor;
       public          postgres    false         �            1255    16599    actualizar_duracion()    FUNCTION     �   CREATE FUNCTION public.actualizar_duracion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.duracion := NEW.fecha_fin - NEW.fecha_inicio;
    RETURN NEW;
END;
$$;
 ,   DROP FUNCTION public.actualizar_duracion();
       public          postgres    false         �            1255    16695     actualizar_puntuacion_producto()    FUNCTION     �  CREATE FUNCTION public.actualizar_puntuacion_producto() RETURNS trigger
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
 7   DROP FUNCTION public.actualizar_puntuacion_producto();
       public          postgres    false         �            1255    16713    fn_crear_promocion_usuario()    FUNCTION     �  CREATE FUNCTION public.fn_crear_promocion_usuario() RETURNS trigger
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
 3   DROP FUNCTION public.fn_crear_promocion_usuario();
       public          postgres    false         �            1255    16690    fn_promocion_compras_usuario()    FUNCTION     �  CREATE FUNCTION public.fn_promocion_compras_usuario() RETURNS trigger
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
 5   DROP FUNCTION public.fn_promocion_compras_usuario();
       public          postgres    false         �            1255    16697    validar_pais_promocion()    FUNCTION     �  CREATE FUNCTION public.validar_pais_promocion() RETURNS trigger
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
 /   DROP FUNCTION public.validar_pais_promocion();
       public          postgres    false         �            1255    16692    verificar_compatibilidad_ios()    FUNCTION     �  CREATE FUNCTION public.verificar_compatibilidad_ios() RETURNS trigger
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
 5   DROP FUNCTION public.verificar_compatibilidad_ios();
       public          postgres    false         �            1259    16558 
   aplicacion    TABLE     �  CREATE TABLE public.aplicacion (
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
    DROP TABLE public.aplicacion;
       public         heap    postgres    false    895         �            1259    16461    artista    TABLE     R  CREATE TABLE public.artista (
    id_artista integer NOT NULL,
    nombre_casa_disquera character varying(100) NOT NULL,
    fecha_inicio date DEFAULT CURRENT_DATE NOT NULL,
    fecha_fin date,
    nom_artistico character varying(100) NOT NULL,
    CONSTRAINT artista_check CHECK (((fecha_fin IS NULL) OR (fecha_fin >= fecha_inicio)))
);
    DROP TABLE public.artista;
       public         heap    postgres    false         �            1259    16460    artista_id_artista_seq    SEQUENCE     �   CREATE SEQUENCE public.artista_id_artista_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.artista_id_artista_seq;
       public          postgres    false    216         �           0    0    artista_id_artista_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.artista_id_artista_seq OWNED BY public.artista.id_artista;
          public          postgres    false    215         �            1259    16504    cancion    TABLE     �  CREATE TABLE public.cancion (
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
    DROP TABLE public.cancion;
       public         heap    postgres    false    874         �            1259    16455    casa_disquera    TABLE     �   CREATE TABLE public.casa_disquera (
    nombre character varying(100) NOT NULL,
    direccion character varying(255) NOT NULL
);
 !   DROP TABLE public.casa_disquera;
       public         heap    postgres    false         �            1259    16621    compras    TABLE     9  CREATE TABLE public.compras (
    id_compra integer NOT NULL,
    id_producto integer NOT NULL,
    id_promo integer,
    id_usuario integer NOT NULL,
    fecha_compra date NOT NULL,
    rating integer,
    monto numeric NOT NULL,
    CONSTRAINT compras_rating_check CHECK (((rating >= 1) AND (rating <= 10)))
);
    DROP TABLE public.compras;
       public         heap    postgres    false         �            1259    16620    compras_id_compra_seq    SEQUENCE     �   CREATE SEQUENCE public.compras_id_compra_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.compras_id_compra_seq;
       public          postgres    false    231         �           0    0    compras_id_compra_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.compras_id_compra_seq OWNED BY public.compras.id_compra;
          public          postgres    false    230         �            1259    16590    usuario    TABLE     |  CREATE TABLE public.usuario (
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
    DROP TABLE public.usuario;
       public         heap    postgres    false         �            1259    17003 	   consulta2    VIEW     0  CREATE VIEW public.consulta2 AS
 SELECT u.num_tdc,
    count(c.id_compra) AS cantidad_compras
   FROM (public.usuario u
     JOIN public.compras c ON ((u.id_usuario = c.id_usuario)))
  WHERE ((u.fecha_venc >= CURRENT_DATE) AND (u.fecha_venc <= (CURRENT_DATE + '3 mons'::interval)))
  GROUP BY u.num_tdc;
    DROP VIEW public.consulta2;
       public          postgres    false    226    226    231    231    226         �            1259    17018 	   consulta3    VIEW     F  CREATE VIEW public.consulta3 AS
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
    DROP VIEW public.consulta3;
       public          postgres    false    223    219    226    226    226    219    231    231    223         �            1259    16527    dispositivo    TABLE     &  CREATE TABLE public.dispositivo (
    id_dispositivo integer NOT NULL,
    capacidad integer,
    generacion public.generacion_disp,
    version_ios character varying(15) NOT NULL,
    modelo character varying(50) NOT NULL,
    CONSTRAINT dispositivo_capacidad_check CHECK ((capacidad > 0))
);
    DROP TABLE public.dispositivo;
       public         heap    postgres    false    881         �            1259    16475    producto    TABLE       CREATE TABLE public.producto (
    id_producto integer NOT NULL,
    puntuacion integer DEFAULT 0,
    costo integer NOT NULL,
    CONSTRAINT producto_costo_check CHECK ((costo > 0)),
    CONSTRAINT producto_puntuacion_check CHECK (((puntuacion >= 0) AND (puntuacion <= 5)))
);
    DROP TABLE public.producto;
       public         heap    postgres    false         �            1259    17023 	   consulta4    VIEW     (  CREATE VIEW public.consulta4 AS
 SELECT a.nombre
   FROM (public.aplicacion a
     JOIN public.producto p ON ((a.id_aplicacion = p.id_producto)))
  WHERE (((a.version_ios)::text <= ( SELECT max((dispositivo.version_ios)::text) AS max
           FROM public.dispositivo)) AND (p.puntuacion > 4));
    DROP VIEW public.consulta4;
       public          postgres    false    223    223    223    220    218    218         �            1259    17038 	   consulta5    VIEW     �  CREATE VIEW public.consulta5 AS
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
    DROP VIEW public.consulta5;
       public          postgres    false    214    219    219    219    216    216         �            1259    16544 	   proveedor    TABLE     y  CREATE TABLE public.proveedor (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    correo character varying(50) NOT NULL,
    direccion character varying(255) NOT NULL,
    fecha_afiliacion date DEFAULT CURRENT_DATE,
    tipo_proveedor public.tipo_proveedor NOT NULL,
    CONSTRAINT proveedor_correo_check CHECK (((correo)::text ~ '^.+@.+\..+$'::text))
);
    DROP TABLE public.proveedor;
       public         heap    postgres    false    888         �            1259    16998 	   consutla1    VIEW     �   CREATE VIEW public.consutla1 AS
 SELECT p.nombre,
    count(*) AS cantidad_aplicaciones
   FROM (public.proveedor p
     JOIN public.aplicacion a ON ((p.id = a.id_proveedor)))
  GROUP BY p.nombre
  ORDER BY (count(*)) DESC
 LIMIT 1;
    DROP VIEW public.consutla1;
       public          postgres    false    222    223    222         �            1259    16579    dispositivo_com    TABLE     |   CREATE TABLE public.dispositivo_com (
    dispositivo character varying(50) NOT NULL,
    id_aplicacion integer NOT NULL
);
 #   DROP TABLE public.dispositivo_com;
       public         heap    postgres    false         �            1259    16610    paises    TABLE     i   CREATE TABLE public.paises (
    nombre_pais character varying(50) NOT NULL,
    id_promocion integer
);
    DROP TABLE public.paises;
       public         heap    postgres    false         �            1259    16474    producto_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public.producto_id_producto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.producto_id_producto_seq;
       public          postgres    false    218         �           0    0    producto_id_producto_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.producto_id_producto_seq OWNED BY public.producto.id_producto;
          public          postgres    false    217         �            1259    16601 	   promocion    TABLE     �  CREATE TABLE public.promocion (
    id_promocion integer NOT NULL,
    descuento integer NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date NOT NULL,
    duracion integer,
    CONSTRAINT check_descuento_valido CHECK (((descuento >= 0) AND (descuento <= 100))),
    CONSTRAINT promocion_check CHECK ((fecha_fin > fecha_inicio)),
    CONSTRAINT promocion_descuento_check CHECK ((descuento > 0))
);
    DROP TABLE public.promocion;
       public         heap    postgres    false         �            1259    16600    promocion_id_promocion_seq    SEQUENCE     �   CREATE SEQUENCE public.promocion_id_promocion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.promocion_id_promocion_seq;
       public          postgres    false    228         �           0    0    promocion_id_promocion_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.promocion_id_promocion_seq OWNED BY public.promocion.id_promocion;
          public          postgres    false    227         �            1259    16543    proveedor_id_seq    SEQUENCE     �   CREATE SEQUENCE public.proveedor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.proveedor_id_seq;
       public          postgres    false    222         �           0    0    proveedor_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.proveedor_id_seq OWNED BY public.proveedor.id;
          public          postgres    false    221         �            1259    16589    usuario_id_usuario_seq    SEQUENCE     �   CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.usuario_id_usuario_seq;
       public          postgres    false    226         �           0    0    usuario_id_usuario_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;
          public          postgres    false    225         �           2604    17249    artista id_artista    DEFAULT     x   ALTER TABLE ONLY public.artista ALTER COLUMN id_artista SET DEFAULT nextval('public.artista_id_artista_seq'::regclass);
 A   ALTER TABLE public.artista ALTER COLUMN id_artista DROP DEFAULT;
       public          postgres    false    216    215    216         �           2604    17250    compras id_compra    DEFAULT     v   ALTER TABLE ONLY public.compras ALTER COLUMN id_compra SET DEFAULT nextval('public.compras_id_compra_seq'::regclass);
 @   ALTER TABLE public.compras ALTER COLUMN id_compra DROP DEFAULT;
       public          postgres    false    230    231    231         �           2604    17251    producto id_producto    DEFAULT     |   ALTER TABLE ONLY public.producto ALTER COLUMN id_producto SET DEFAULT nextval('public.producto_id_producto_seq'::regclass);
 C   ALTER TABLE public.producto ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    217    218    218         �           2604    17252    promocion id_promocion    DEFAULT     �   ALTER TABLE ONLY public.promocion ALTER COLUMN id_promocion SET DEFAULT nextval('public.promocion_id_promocion_seq'::regclass);
 E   ALTER TABLE public.promocion ALTER COLUMN id_promocion DROP DEFAULT;
       public          postgres    false    227    228    228         �           2604    17253    proveedor id    DEFAULT     l   ALTER TABLE ONLY public.proveedor ALTER COLUMN id SET DEFAULT nextval('public.proveedor_id_seq'::regclass);
 ;   ALTER TABLE public.proveedor ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    221    222         �           2604    17254    usuario id_usuario    DEFAULT     x   ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);
 A   ALTER TABLE public.usuario ALTER COLUMN id_usuario DROP DEFAULT;
       public          postgres    false    225    226    226         �          0    16558 
   aplicacion 
   TABLE DATA           �   COPY public.aplicacion ("tama¤o_mb", version, nombre, version_ios, tematica, id_proveedor, id_aplicacion, descripcion) FROM stdin;
    public          postgres    false    223       3485.dat �          0    16461    artista 
   TABLE DATA           k   COPY public.artista (id_artista, nombre_casa_disquera, fecha_inicio, fecha_fin, nom_artistico) FROM stdin;
    public          postgres    false    216       3478.dat �          0    16504    cancion 
   TABLE DATA           }   COPY public.cancion (id_cancion, id_artista, genero, nom_disco, duracion, fecha_lanz, nomb_cancion, un_vendidas) FROM stdin;
    public          postgres    false    219       3481.dat �          0    16455    casa_disquera 
   TABLE DATA           :   COPY public.casa_disquera (nombre, direccion) FROM stdin;
    public          postgres    false    214       3476.dat �          0    16621    compras 
   TABLE DATA           l   COPY public.compras (id_compra, id_producto, id_promo, id_usuario, fecha_compra, rating, monto) FROM stdin;
    public          postgres    false    231       3493.dat �          0    16527    dispositivo 
   TABLE DATA           a   COPY public.dispositivo (id_dispositivo, capacidad, generacion, version_ios, modelo) FROM stdin;
    public          postgres    false    220       3482.dat �          0    16579    dispositivo_com 
   TABLE DATA           E   COPY public.dispositivo_com (dispositivo, id_aplicacion) FROM stdin;
    public          postgres    false    224       3486.dat �          0    16610    paises 
   TABLE DATA           ;   COPY public.paises (nombre_pais, id_promocion) FROM stdin;
    public          postgres    false    229       3491.dat �          0    16475    producto 
   TABLE DATA           B   COPY public.producto (id_producto, puntuacion, costo) FROM stdin;
    public          postgres    false    218       3480.dat �          0    16601 	   promocion 
   TABLE DATA           _   COPY public.promocion (id_promocion, descuento, fecha_inicio, fecha_fin, duracion) FROM stdin;
    public          postgres    false    228       3490.dat �          0    16544 	   proveedor 
   TABLE DATA           d   COPY public.proveedor (id, nombre, correo, direccion, fecha_afiliacion, tipo_proveedor) FROM stdin;
    public          postgres    false    222       3484.dat �          0    16590    usuario 
   TABLE DATA           v   COPY public.usuario (id_usuario, correo, nombre, apellido, num_tdc, fecha_venc, cod_vvt, direccion, pais) FROM stdin;
    public          postgres    false    226       3488.dat �           0    0    artista_id_artista_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.artista_id_artista_seq', 36, true);
          public          postgres    false    215         �           0    0    compras_id_compra_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.compras_id_compra_seq', 56, true);
          public          postgres    false    230         �           0    0    producto_id_producto_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.producto_id_producto_seq', 20, true);
          public          postgres    false    217         �           0    0    promocion_id_promocion_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.promocion_id_promocion_seq', 38, true);
          public          postgres    false    227         �           0    0    proveedor_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.proveedor_id_seq', 10, true);
          public          postgres    false    221         �           0    0    usuario_id_usuario_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 10, true);
          public          postgres    false    225         �           2606    16573    aplicacion aplicacion_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT aplicacion_pkey PRIMARY KEY (id_aplicacion);
 D   ALTER TABLE ONLY public.aplicacion DROP CONSTRAINT aplicacion_pkey;
       public            postgres    false    223         �           2606    16468    artista artista_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.artista
    ADD CONSTRAINT artista_pkey PRIMARY KEY (id_artista);
 >   ALTER TABLE ONLY public.artista DROP CONSTRAINT artista_pkey;
       public            postgres    false    216         �           2606    16513    cancion cancion_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT cancion_pkey PRIMARY KEY (id_cancion);
 >   ALTER TABLE ONLY public.cancion DROP CONSTRAINT cancion_pkey;
       public            postgres    false    219         �           2606    16459     casa_disquera casa_disquera_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.casa_disquera
    ADD CONSTRAINT casa_disquera_pkey PRIMARY KEY (nombre);
 J   ALTER TABLE ONLY public.casa_disquera DROP CONSTRAINT casa_disquera_pkey;
       public            postgres    false    214         �           2606    16629    compras compras_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_pkey PRIMARY KEY (id_compra, fecha_compra);
 >   ALTER TABLE ONLY public.compras DROP CONSTRAINT compras_pkey;
       public            postgres    false    231    231         �           2606    16583 $   dispositivo_com dispositivo_com_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.dispositivo_com
    ADD CONSTRAINT dispositivo_com_pkey PRIMARY KEY (dispositivo);
 N   ALTER TABLE ONLY public.dispositivo_com DROP CONSTRAINT dispositivo_com_pkey;
       public            postgres    false    224         �           2606    16534    dispositivo dispositivo_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.dispositivo
    ADD CONSTRAINT dispositivo_pkey PRIMARY KEY (id_dispositivo);
 F   ALTER TABLE ONLY public.dispositivo DROP CONSTRAINT dispositivo_pkey;
       public            postgres    false    220         �           2606    16614    paises paises_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.paises
    ADD CONSTRAINT paises_pkey PRIMARY KEY (nombre_pais);
 <   ALTER TABLE ONLY public.paises DROP CONSTRAINT paises_pkey;
       public            postgres    false    229         �           2606    16669    producto producto_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_pkey PRIMARY KEY (id_producto);
 @   ALTER TABLE ONLY public.producto DROP CONSTRAINT producto_pkey;
       public            postgres    false    218         �           2606    16608    promocion promocion_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.promocion
    ADD CONSTRAINT promocion_pkey PRIMARY KEY (id_promocion);
 B   ALTER TABLE ONLY public.promocion DROP CONSTRAINT promocion_pkey;
       public            postgres    false    228         �           2606    16553    proveedor proveedor_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.proveedor DROP CONSTRAINT proveedor_pkey;
       public            postgres    false    222         �           2606    16598    usuario usuario_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);
 >   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_pkey;
       public            postgres    false    226         �           2620    16696 *   compras actualizar_puntuacion_after_compra    TRIGGER     �   CREATE TRIGGER actualizar_puntuacion_after_compra AFTER INSERT OR UPDATE OF rating ON public.compras FOR EACH ROW WHEN ((new.rating IS NOT NULL)) EXECUTE FUNCTION public.actualizar_puntuacion_producto();
 C   DROP TRIGGER actualizar_puntuacion_after_compra ON public.compras;
       public          postgres    false    231    238    231    231         �           2620    16714 )   compras tr_crear_promocion_despues_compra    TRIGGER     �   CREATE TRIGGER tr_crear_promocion_despues_compra AFTER INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.fn_crear_promocion_usuario();
 B   DROP TRIGGER tr_crear_promocion_despues_compra ON public.compras;
       public          postgres    false    250    231         �           2620    16691    compras tr_promocion_compras    TRIGGER     �   CREATE TRIGGER tr_promocion_compras AFTER INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.fn_promocion_compras_usuario();
 5   DROP TRIGGER tr_promocion_compras ON public.compras;
       public          postgres    false    231    252         �           2620    16698 ,   compras validar_pais_promocion_before_insert    TRIGGER     �   CREATE TRIGGER validar_pais_promocion_before_insert BEFORE INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.validar_pais_promocion();
 E   DROP TRIGGER validar_pais_promocion_before_insert ON public.compras;
       public          postgres    false    231    251                     2620    16693 2   compras verificar_compatibilidad_ios_before_insert    TRIGGER     �   CREATE TRIGGER verificar_compatibilidad_ios_before_insert BEFORE INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.verificar_compatibilidad_ios();
 K   DROP TRIGGER verificar_compatibilidad_ios_before_insert ON public.compras;
       public          postgres    false    253    231         �           2606    16680 !   aplicacion fk_aplicacion_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT fk_aplicacion_producto FOREIGN KEY (id_aplicacion) REFERENCES public.producto(id_producto);
 K   ALTER TABLE ONLY public.aplicacion DROP CONSTRAINT fk_aplicacion_producto;
       public          postgres    false    218    223    3294         �           2606    16567 "   aplicacion fk_aplicacion_proveedor    FK CONSTRAINT     �   ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT fk_aplicacion_proveedor FOREIGN KEY (id_proveedor) REFERENCES public.proveedor(id);
 L   ALTER TABLE ONLY public.aplicacion DROP CONSTRAINT fk_aplicacion_proveedor;
       public          postgres    false    3300    222    223         �           2606    16469     artista fk_artista_casa_disquera    FK CONSTRAINT     �   ALTER TABLE ONLY public.artista
    ADD CONSTRAINT fk_artista_casa_disquera FOREIGN KEY (nombre_casa_disquera) REFERENCES public.casa_disquera(nombre) ON UPDATE CASCADE ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.artista DROP CONSTRAINT fk_artista_casa_disquera;
       public          postgres    false    3290    214    216         �           2606    16519    cancion fk_cancion_artista    FK CONSTRAINT     �   ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT fk_cancion_artista FOREIGN KEY (id_artista) REFERENCES public.artista(id_artista);
 D   ALTER TABLE ONLY public.cancion DROP CONSTRAINT fk_cancion_artista;
       public          postgres    false    3292    219    216         �           2606    16670    cancion fk_cancion_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT fk_cancion_producto FOREIGN KEY (id_cancion) REFERENCES public.producto(id_producto);
 E   ALTER TABLE ONLY public.cancion DROP CONSTRAINT fk_cancion_producto;
       public          postgres    false    218    219    3294         �           2606    16685    compras fk_compras_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_producto FOREIGN KEY (id_producto) REFERENCES public.producto(id_producto);
 E   ALTER TABLE ONLY public.compras DROP CONSTRAINT fk_compras_producto;
       public          postgres    false    231    3294    218         �           2606    16635    compras fk_compras_promo    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_promo FOREIGN KEY (id_promo) REFERENCES public.promocion(id_promocion);
 B   ALTER TABLE ONLY public.compras DROP CONSTRAINT fk_compras_promo;
       public          postgres    false    3308    228    231         �           2606    16640    compras fk_compras_usuario    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);
 D   ALTER TABLE ONLY public.compras DROP CONSTRAINT fk_compras_usuario;
       public          postgres    false    3306    226    231         �           2606    16584 -   dispositivo_com fk_dispositivo_com_aplicacion    FK CONSTRAINT     �   ALTER TABLE ONLY public.dispositivo_com
    ADD CONSTRAINT fk_dispositivo_com_aplicacion FOREIGN KEY (id_aplicacion) REFERENCES public.aplicacion(id_aplicacion);
 W   ALTER TABLE ONLY public.dispositivo_com DROP CONSTRAINT fk_dispositivo_com_aplicacion;
       public          postgres    false    3302    223    224         �           2606    16675 #   dispositivo fk_dispositivo_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.dispositivo
    ADD CONSTRAINT fk_dispositivo_producto FOREIGN KEY (id_dispositivo) REFERENCES public.producto(id_producto);
 M   ALTER TABLE ONLY public.dispositivo DROP CONSTRAINT fk_dispositivo_producto;
       public          postgres    false    218    220    3294         �           2606    16615    paises fk_key_promocion    FK CONSTRAINT     �   ALTER TABLE ONLY public.paises
    ADD CONSTRAINT fk_key_promocion FOREIGN KEY (id_promocion) REFERENCES public.promocion(id_promocion);
 A   ALTER TABLE ONLY public.paises DROP CONSTRAINT fk_key_promocion;
       public          postgres    false    228    229    3308                                                                                                    3485.dat                                                                                            0000600 0004000 0002000 00000001624 14526470135 0014267 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        150	1.0	App Cocina	10	cocina	1	1	App de Recetas
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


                                                                                                            3478.dat                                                                                            0000600 0004000 0002000 00000003147 14526470135 0014273 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Disquera A	2023-01-01	\N	Artista Uno
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


                                                                                                                                                                                                                                                                                                                                                                                                                         3481.dat                                                                                            0000600 0004000 0002000 00000002250 14526470135 0014257 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	1	Pop	µlbum A	180	2023-01-01	Canci¢n A1	1000
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


                                                                                                                                                                                                                                                                                                                                                        3476.dat                                                                                            0000600 0004000 0002000 00000001252 14526470135 0014264 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        Disquera B	Avenida 456, Ciudad B
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


                                                                                                                                                                                                                                                                                                                                                      3493.dat                                                                                            0000600 0004000 0002000 00000002031 14526470135 0014257 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        14	1	\N	1	2023-11-16	5	100.0
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


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       3482.dat                                                                                            0000600 0004000 0002000 00000000431 14526470135 0014257 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        11	64	Gen1	iOS 10	Modelo A
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


                                                                                                                                                                                                                                       3486.dat                                                                                            0000600 0004000 0002000 00000000070 14526470135 0014262 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        11	1
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


                                                                                                                                                                                                                                                                                                                                                                                                                                                                        3491.dat                                                                                            0000600 0004000 0002000 00000000177 14526470135 0014266 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        Espa¤a	1
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


                                                                                                                                                                                                                                                                                                                                                                                                 3480.dat                                                                                            0000600 0004000 0002000 00000000517 14526470135 0014262 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        13	4	250
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


                                                                                                                                                                                 3490.dat                                                                                            0000600 0004000 0002000 00000002226 14526470135 0014262 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	10	2023-01-01	2023-01-31	30
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


                                                                                                                                                                                                                                                                                                                                                                          3484.dat                                                                                            0000600 0004000 0002000 00000001516 14526470135 0014266 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Proveedor 1	correo1@proveedor.com	Direcci¢n 1	2023-11-16	desarrollador
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


                                                                                                                                                                                  3488.dat                                                                                            0000600 0004000 0002000 00000002004 14526470135 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        3	luis.gomez@example.com	Luis	Gomez	9999000011112222	2025-03-01	345	789 Callejon Inventado	Colombia
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


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            restore.sql                                                                                         0000600 0004000 0002000 00000074623 14526470135 0015407 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        --
-- NOTE:
--
-- File paths need to be edited. Search for $$PATH$$ and
-- replace it with the path to the directory containing
-- the extracted data files.
--
--
-- PostgreSQL database dump
--

-- Dumped from database version 15.5
-- Dumped by pg_dump version 16.1

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

DROP DATABASE proyecto_fase2;
--
-- Name: proyecto_fase2; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE proyecto_fase2 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Latin America.1252';


ALTER DATABASE proyecto_fase2 OWNER TO postgres;

\connect proyecto_fase2

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
-- Name: generacion_disp; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.generacion_disp AS character varying(10)
	CONSTRAINT generacion_disp_check CHECK (((VALUE)::text = ANY ((ARRAY['Gen1'::character varying, 'Gen2'::character varying, 'Gen3'::character varying, 'Gen4'::character varying, 'Gen5'::character varying])::text[])));


ALTER DOMAIN public.generacion_disp OWNER TO postgres;

--
-- Name: genero_musical; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.genero_musical AS character varying(50)
	CONSTRAINT genero_musical_check CHECK (((VALUE)::text = ANY ((ARRAY['Rock'::character varying, 'Pop'::character varying, 'Jazz'::character varying, 'Cl sica'::character varying, 'Electr¢nica'::character varying, 'Reggae'::character varying, 'Hip Hop'::character varying, 'Blues'::character varying, 'Country'::character varying, 'Folk'::character varying])::text[])));


ALTER DOMAIN public.genero_musical OWNER TO postgres;

--
-- Name: tematica_app; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.tematica_app AS character varying(50)
	CONSTRAINT tematica_app_check CHECK (((VALUE)::text = ANY ((ARRAY['cocina'::character varying, 'lectura'::character varying, 'juegos'::character varying, 'educacion'::character varying, 'salud'::character varying, 'deporte'::character varying, 'musica'::character varying, 'noticias'::character varying])::text[])));


ALTER DOMAIN public.tematica_app OWNER TO postgres;

--
-- Name: tipo_proveedor; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.tipo_proveedor AS character varying(20)
	CONSTRAINT tipo_proveedor_check CHECK (((VALUE)::text = ANY ((ARRAY['desarrollador'::character varying, 'empresa'::character varying])::text[])));


ALTER DOMAIN public.tipo_proveedor OWNER TO postgres;

--
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
-- Name: artista_id_artista_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.artista_id_artista_seq OWNED BY public.artista.id_artista;


--
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
-- Name: casa_disquera; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.casa_disquera (
    nombre character varying(100) NOT NULL,
    direccion character varying(255) NOT NULL
);


ALTER TABLE public.casa_disquera OWNER TO postgres;

--
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
-- Name: compras_id_compra_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.compras_id_compra_seq OWNED BY public.compras.id_compra;


--
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
-- Name: dispositivo_com; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dispositivo_com (
    dispositivo character varying(50) NOT NULL,
    id_aplicacion integer NOT NULL
);


ALTER TABLE public.dispositivo_com OWNER TO postgres;

--
-- Name: paises; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paises (
    nombre_pais character varying(50) NOT NULL,
    id_promocion integer
);


ALTER TABLE public.paises OWNER TO postgres;

--
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
-- Name: producto_id_producto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.producto_id_producto_seq OWNED BY public.producto.id_producto;


--
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
-- Name: promocion_id_promocion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.promocion_id_promocion_seq OWNED BY public.promocion.id_promocion;


--
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
-- Name: proveedor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proveedor_id_seq OWNED BY public.proveedor.id;


--
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
-- Name: usuario_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;


--
-- Name: artista id_artista; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artista ALTER COLUMN id_artista SET DEFAULT nextval('public.artista_id_artista_seq'::regclass);


--
-- Name: compras id_compra; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras ALTER COLUMN id_compra SET DEFAULT nextval('public.compras_id_compra_seq'::regclass);


--
-- Name: producto id_producto; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto ALTER COLUMN id_producto SET DEFAULT nextval('public.producto_id_producto_seq'::regclass);


--
-- Name: promocion id_promocion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promocion ALTER COLUMN id_promocion SET DEFAULT nextval('public.promocion_id_promocion_seq'::regclass);


--
-- Name: proveedor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor ALTER COLUMN id SET DEFAULT nextval('public.proveedor_id_seq'::regclass);


--
-- Name: usuario id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);


--
-- Data for Name: aplicacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.aplicacion ("tama¤o_mb", version, nombre, version_ios, tematica, id_proveedor, id_aplicacion, descripcion) FROM stdin;
\.
COPY public.aplicacion ("tama¤o_mb", version, nombre, version_ios, tematica, id_proveedor, id_aplicacion, descripcion) FROM '$$PATH$$/3485.dat';

--
-- Data for Name: artista; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.artista (id_artista, nombre_casa_disquera, fecha_inicio, fecha_fin, nom_artistico) FROM stdin;
\.
COPY public.artista (id_artista, nombre_casa_disquera, fecha_inicio, fecha_fin, nom_artistico) FROM '$$PATH$$/3478.dat';

--
-- Data for Name: cancion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cancion (id_cancion, id_artista, genero, nom_disco, duracion, fecha_lanz, nomb_cancion, un_vendidas) FROM stdin;
\.
COPY public.cancion (id_cancion, id_artista, genero, nom_disco, duracion, fecha_lanz, nomb_cancion, un_vendidas) FROM '$$PATH$$/3481.dat';

--
-- Data for Name: casa_disquera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.casa_disquera (nombre, direccion) FROM stdin;
\.
COPY public.casa_disquera (nombre, direccion) FROM '$$PATH$$/3476.dat';

--
-- Data for Name: compras; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras (id_compra, id_producto, id_promo, id_usuario, fecha_compra, rating, monto) FROM stdin;
\.
COPY public.compras (id_compra, id_producto, id_promo, id_usuario, fecha_compra, rating, monto) FROM '$$PATH$$/3493.dat';

--
-- Data for Name: dispositivo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dispositivo (id_dispositivo, capacidad, generacion, version_ios, modelo) FROM stdin;
\.
COPY public.dispositivo (id_dispositivo, capacidad, generacion, version_ios, modelo) FROM '$$PATH$$/3482.dat';

--
-- Data for Name: dispositivo_com; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dispositivo_com (dispositivo, id_aplicacion) FROM stdin;
\.
COPY public.dispositivo_com (dispositivo, id_aplicacion) FROM '$$PATH$$/3486.dat';

--
-- Data for Name: paises; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.paises (nombre_pais, id_promocion) FROM stdin;
\.
COPY public.paises (nombre_pais, id_promocion) FROM '$$PATH$$/3491.dat';

--
-- Data for Name: producto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.producto (id_producto, puntuacion, costo) FROM stdin;
\.
COPY public.producto (id_producto, puntuacion, costo) FROM '$$PATH$$/3480.dat';

--
-- Data for Name: promocion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promocion (id_promocion, descuento, fecha_inicio, fecha_fin, duracion) FROM stdin;
\.
COPY public.promocion (id_promocion, descuento, fecha_inicio, fecha_fin, duracion) FROM '$$PATH$$/3490.dat';

--
-- Data for Name: proveedor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.proveedor (id, nombre, correo, direccion, fecha_afiliacion, tipo_proveedor) FROM stdin;
\.
COPY public.proveedor (id, nombre, correo, direccion, fecha_afiliacion, tipo_proveedor) FROM '$$PATH$$/3484.dat';

--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario (id_usuario, correo, nombre, apellido, num_tdc, fecha_venc, cod_vvt, direccion, pais) FROM stdin;
\.
COPY public.usuario (id_usuario, correo, nombre, apellido, num_tdc, fecha_venc, cod_vvt, direccion, pais) FROM '$$PATH$$/3488.dat';

--
-- Name: artista_id_artista_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.artista_id_artista_seq', 36, true);


--
-- Name: compras_id_compra_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.compras_id_compra_seq', 56, true);


--
-- Name: producto_id_producto_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.producto_id_producto_seq', 20, true);


--
-- Name: promocion_id_promocion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.promocion_id_promocion_seq', 38, true);


--
-- Name: proveedor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.proveedor_id_seq', 10, true);


--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 10, true);


--
-- Name: aplicacion aplicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT aplicacion_pkey PRIMARY KEY (id_aplicacion);


--
-- Name: artista artista_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artista
    ADD CONSTRAINT artista_pkey PRIMARY KEY (id_artista);


--
-- Name: cancion cancion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT cancion_pkey PRIMARY KEY (id_cancion);


--
-- Name: casa_disquera casa_disquera_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.casa_disquera
    ADD CONSTRAINT casa_disquera_pkey PRIMARY KEY (nombre);


--
-- Name: compras compras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_pkey PRIMARY KEY (id_compra, fecha_compra);


--
-- Name: dispositivo_com dispositivo_com_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dispositivo_com
    ADD CONSTRAINT dispositivo_com_pkey PRIMARY KEY (dispositivo);


--
-- Name: dispositivo dispositivo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dispositivo
    ADD CONSTRAINT dispositivo_pkey PRIMARY KEY (id_dispositivo);


--
-- Name: paises paises_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paises
    ADD CONSTRAINT paises_pkey PRIMARY KEY (nombre_pais);


--
-- Name: producto producto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_pkey PRIMARY KEY (id_producto);


--
-- Name: promocion promocion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promocion
    ADD CONSTRAINT promocion_pkey PRIMARY KEY (id_promocion);


--
-- Name: proveedor proveedor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- Name: compras actualizar_puntuacion_after_compra; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER actualizar_puntuacion_after_compra AFTER INSERT OR UPDATE OF rating ON public.compras FOR EACH ROW WHEN ((new.rating IS NOT NULL)) EXECUTE FUNCTION public.actualizar_puntuacion_producto();


--
-- Name: compras tr_crear_promocion_despues_compra; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_crear_promocion_despues_compra AFTER INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.fn_crear_promocion_usuario();


--
-- Name: compras tr_promocion_compras; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_promocion_compras AFTER INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.fn_promocion_compras_usuario();


--
-- Name: compras validar_pais_promocion_before_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER validar_pais_promocion_before_insert BEFORE INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.validar_pais_promocion();


--
-- Name: compras verificar_compatibilidad_ios_before_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER verificar_compatibilidad_ios_before_insert BEFORE INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.verificar_compatibilidad_ios();


--
-- Name: aplicacion fk_aplicacion_producto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT fk_aplicacion_producto FOREIGN KEY (id_aplicacion) REFERENCES public.producto(id_producto);


--
-- Name: aplicacion fk_aplicacion_proveedor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT fk_aplicacion_proveedor FOREIGN KEY (id_proveedor) REFERENCES public.proveedor(id);


--
-- Name: artista fk_artista_casa_disquera; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artista
    ADD CONSTRAINT fk_artista_casa_disquera FOREIGN KEY (nombre_casa_disquera) REFERENCES public.casa_disquera(nombre) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cancion fk_cancion_artista; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT fk_cancion_artista FOREIGN KEY (id_artista) REFERENCES public.artista(id_artista);


--
-- Name: cancion fk_cancion_producto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT fk_cancion_producto FOREIGN KEY (id_cancion) REFERENCES public.producto(id_producto);


--
-- Name: compras fk_compras_producto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_producto FOREIGN KEY (id_producto) REFERENCES public.producto(id_producto);


--
-- Name: compras fk_compras_promo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_promo FOREIGN KEY (id_promo) REFERENCES public.promocion(id_promocion);


--
-- Name: compras fk_compras_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- Name: dispositivo_com fk_dispositivo_com_aplicacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dispositivo_com
    ADD CONSTRAINT fk_dispositivo_com_aplicacion FOREIGN KEY (id_aplicacion) REFERENCES public.aplicacion(id_aplicacion);


--
-- Name: dispositivo fk_dispositivo_producto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dispositivo
    ADD CONSTRAINT fk_dispositivo_producto FOREIGN KEY (id_dispositivo) REFERENCES public.producto(id_producto);


--
-- Name: paises fk_key_promocion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paises
    ADD CONSTRAINT fk_key_promocion FOREIGN KEY (id_promocion) REFERENCES public.promocion(id_promocion);


--
-- PostgreSQL database dump complete
--

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             