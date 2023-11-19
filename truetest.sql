PGDMP  5                
    {            proyecto_fase2    15.5    16.1 _    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16454    proyecto_fase2    DATABASE     �   CREATE DATABASE proyecto_fase2 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Latin America.1252';
    DROP DATABASE proyecto_fase2;
                postgres    false            q           1247    16525    generacion_disp    DOMAIN       CREATE DOMAIN public.generacion_disp AS character varying(10)
	CONSTRAINT generacion_disp_check CHECK (((VALUE)::text = ANY ((ARRAY['Gen1'::character varying, 'Gen2'::character varying, 'Gen3'::character varying, 'Gen4'::character varying, 'Gen5'::character varying])::text[])));
 $   DROP DOMAIN public.generacion_disp;
       public          postgres    false            j           1247    16485    genero_musical    DOMAIN     �  CREATE DOMAIN public.genero_musical AS character varying(50)
	CONSTRAINT genero_musical_check CHECK (((VALUE)::text = ANY ((ARRAY['Rock'::character varying, 'Pop'::character varying, 'Jazz'::character varying, 'Cl sica'::character varying, 'Electr¢nica'::character varying, 'Reggae'::character varying, 'Hip Hop'::character varying, 'Blues'::character varying, 'Country'::character varying, 'Folk'::character varying])::text[])));
 #   DROP DOMAIN public.genero_musical;
       public          postgres    false                       1247    16555    tematica_app    DOMAIN     y  CREATE DOMAIN public.tematica_app AS character varying(50)
	CONSTRAINT tematica_app_check CHECK (((VALUE)::text = ANY ((ARRAY['cocina'::character varying, 'lectura'::character varying, 'juegos'::character varying, 'educacion'::character varying, 'salud'::character varying, 'deporte'::character varying, 'musica'::character varying, 'noticias'::character varying])::text[])));
 !   DROP DOMAIN public.tematica_app;
       public          postgres    false            x           1247    16541    tipo_proveedor    DOMAIN     �   CREATE DOMAIN public.tipo_proveedor AS character varying(20)
	CONSTRAINT tipo_proveedor_check CHECK (((VALUE)::text = ANY ((ARRAY['desarrollador'::character varying, 'empresa'::character varying])::text[])));
 #   DROP DOMAIN public.tipo_proveedor;
       public          postgres    false            �            1255    16599    actualizar_duracion()    FUNCTION     �   CREATE FUNCTION public.actualizar_duracion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.duracion := NEW.fecha_fin - NEW.fecha_inicio;
    RETURN NEW;
END;
$$;
 ,   DROP FUNCTION public.actualizar_duracion();
       public          postgres    false            �            1255    16695     actualizar_puntuacion_producto()    FUNCTION     �  CREATE FUNCTION public.actualizar_puntuacion_producto() RETURNS trigger
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
       public          postgres    false            �            1255    16713    fn_crear_promocion_usuario()    FUNCTION     �  CREATE FUNCTION public.fn_crear_promocion_usuario() RETURNS trigger
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
       public          postgres    false            �            1255    16690    fn_promocion_compras_usuario()    FUNCTION     �  CREATE FUNCTION public.fn_promocion_compras_usuario() RETURNS trigger
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
       public          postgres    false            �            1255    16697    validar_pais_promocion()    FUNCTION     �  CREATE FUNCTION public.validar_pais_promocion() RETURNS trigger
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
       public          postgres    false            �            1255    16692    verificar_compatibilidad_ios()    FUNCTION     �  CREATE FUNCTION public.verificar_compatibilidad_ios() RETURNS trigger
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
       public          postgres    false            �            1259    16558 
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
       public         heap    postgres    false    895            �            1259    16461    artista    TABLE     R  CREATE TABLE public.artista (
    id_artista integer NOT NULL,
    nombre_casa_disquera character varying(100) NOT NULL,
    fecha_inicio date DEFAULT CURRENT_DATE NOT NULL,
    fecha_fin date,
    nom_artistico character varying(100) NOT NULL,
    CONSTRAINT artista_check CHECK (((fecha_fin IS NULL) OR (fecha_fin >= fecha_inicio)))
);
    DROP TABLE public.artista;
       public         heap    postgres    false            �            1259    16460    artista_id_artista_seq    SEQUENCE     �   CREATE SEQUENCE public.artista_id_artista_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.artista_id_artista_seq;
       public          postgres    false    216            �           0    0    artista_id_artista_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.artista_id_artista_seq OWNED BY public.artista.id_artista;
          public          postgres    false    215            �            1259    16504    cancion    TABLE     �  CREATE TABLE public.cancion (
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
       public         heap    postgres    false    874            �            1259    16455    casa_disquera    TABLE     �   CREATE TABLE public.casa_disquera (
    nombre character varying(100) NOT NULL,
    direccion character varying(255) NOT NULL
);
 !   DROP TABLE public.casa_disquera;
       public         heap    postgres    false            �            1259    16621    compras    TABLE     9  CREATE TABLE public.compras (
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
       public         heap    postgres    false            �            1259    16620    compras_id_compra_seq    SEQUENCE     �   CREATE SEQUENCE public.compras_id_compra_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.compras_id_compra_seq;
       public          postgres    false    231            �           0    0    compras_id_compra_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.compras_id_compra_seq OWNED BY public.compras.id_compra;
          public          postgres    false    230            �            1259    16590    usuario    TABLE     |  CREATE TABLE public.usuario (
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
       public         heap    postgres    false            �            1259    17003 	   consulta2    VIEW     0  CREATE VIEW public.consulta2 AS
 SELECT u.num_tdc,
    count(c.id_compra) AS cantidad_compras
   FROM (public.usuario u
     JOIN public.compras c ON ((u.id_usuario = c.id_usuario)))
  WHERE ((u.fecha_venc >= CURRENT_DATE) AND (u.fecha_venc <= (CURRENT_DATE + '3 mons'::interval)))
  GROUP BY u.num_tdc;
    DROP VIEW public.consulta2;
       public          postgres    false    226    226    231    231    226            �            1259    17018 	   consulta3    VIEW     F  CREATE VIEW public.consulta3 AS
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
       public          postgres    false    223    219    226    226    226    219    231    231    223            �            1259    16527    dispositivo    TABLE     &  CREATE TABLE public.dispositivo (
    id_dispositivo integer NOT NULL,
    capacidad integer,
    generacion public.generacion_disp,
    version_ios character varying(15) NOT NULL,
    modelo character varying(50) NOT NULL,
    CONSTRAINT dispositivo_capacidad_check CHECK ((capacidad > 0))
);
    DROP TABLE public.dispositivo;
       public         heap    postgres    false    881            �            1259    16475    producto    TABLE       CREATE TABLE public.producto (
    id_producto integer NOT NULL,
    puntuacion integer DEFAULT 0,
    costo integer NOT NULL,
    CONSTRAINT producto_costo_check CHECK ((costo > 0)),
    CONSTRAINT producto_puntuacion_check CHECK (((puntuacion >= 0) AND (puntuacion <= 5)))
);
    DROP TABLE public.producto;
       public         heap    postgres    false            �            1259    17023 	   consulta4    VIEW     (  CREATE VIEW public.consulta4 AS
 SELECT a.nombre
   FROM (public.aplicacion a
     JOIN public.producto p ON ((a.id_aplicacion = p.id_producto)))
  WHERE (((a.version_ios)::text <= ( SELECT max((dispositivo.version_ios)::text) AS max
           FROM public.dispositivo)) AND (p.puntuacion > 4));
    DROP VIEW public.consulta4;
       public          postgres    false    223    223    223    220    218    218            �            1259    17038 	   consulta5    VIEW     �  CREATE VIEW public.consulta5 AS
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
       public          postgres    false    214    219    219    219    216    216            �            1259    16544 	   proveedor    TABLE     y  CREATE TABLE public.proveedor (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    correo character varying(50) NOT NULL,
    direccion character varying(255) NOT NULL,
    fecha_afiliacion date DEFAULT CURRENT_DATE,
    tipo_proveedor public.tipo_proveedor NOT NULL,
    CONSTRAINT proveedor_correo_check CHECK (((correo)::text ~ '^.+@.+\..+$'::text))
);
    DROP TABLE public.proveedor;
       public         heap    postgres    false    888            �            1259    16998 	   consutla1    VIEW     �   CREATE VIEW public.consutla1 AS
 SELECT p.nombre,
    count(*) AS cantidad_aplicaciones
   FROM (public.proveedor p
     JOIN public.aplicacion a ON ((p.id = a.id_proveedor)))
  GROUP BY p.nombre
  ORDER BY (count(*)) DESC
 LIMIT 1;
    DROP VIEW public.consutla1;
       public          postgres    false    222    223    222            �            1259    16579    dispositivo_com    TABLE     |   CREATE TABLE public.dispositivo_com (
    dispositivo character varying(50) NOT NULL,
    id_aplicacion integer NOT NULL
);
 #   DROP TABLE public.dispositivo_com;
       public         heap    postgres    false            �            1259    16610    paises    TABLE     i   CREATE TABLE public.paises (
    nombre_pais character varying(50) NOT NULL,
    id_promocion integer
);
    DROP TABLE public.paises;
       public         heap    postgres    false            �            1259    16474    producto_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public.producto_id_producto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.producto_id_producto_seq;
       public          postgres    false    218            �           0    0    producto_id_producto_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.producto_id_producto_seq OWNED BY public.producto.id_producto;
          public          postgres    false    217            �            1259    16601 	   promocion    TABLE     �  CREATE TABLE public.promocion (
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
       public         heap    postgres    false            �            1259    16600    promocion_id_promocion_seq    SEQUENCE     �   CREATE SEQUENCE public.promocion_id_promocion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.promocion_id_promocion_seq;
       public          postgres    false    228            �           0    0    promocion_id_promocion_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.promocion_id_promocion_seq OWNED BY public.promocion.id_promocion;
          public          postgres    false    227            �            1259    16543    proveedor_id_seq    SEQUENCE     �   CREATE SEQUENCE public.proveedor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.proveedor_id_seq;
       public          postgres    false    222            �           0    0    proveedor_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.proveedor_id_seq OWNED BY public.proveedor.id;
          public          postgres    false    221            �            1259    16589    usuario_id_usuario_seq    SEQUENCE     �   CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.usuario_id_usuario_seq;
       public          postgres    false    226            �           0    0    usuario_id_usuario_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;
          public          postgres    false    225            �           2604    17249    artista id_artista    DEFAULT     x   ALTER TABLE ONLY public.artista ALTER COLUMN id_artista SET DEFAULT nextval('public.artista_id_artista_seq'::regclass);
 A   ALTER TABLE public.artista ALTER COLUMN id_artista DROP DEFAULT;
       public          postgres    false    216    215    216            �           2604    17250    compras id_compra    DEFAULT     v   ALTER TABLE ONLY public.compras ALTER COLUMN id_compra SET DEFAULT nextval('public.compras_id_compra_seq'::regclass);
 @   ALTER TABLE public.compras ALTER COLUMN id_compra DROP DEFAULT;
       public          postgres    false    230    231    231            �           2604    17251    producto id_producto    DEFAULT     |   ALTER TABLE ONLY public.producto ALTER COLUMN id_producto SET DEFAULT nextval('public.producto_id_producto_seq'::regclass);
 C   ALTER TABLE public.producto ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    217    218    218            �           2604    17252    promocion id_promocion    DEFAULT     �   ALTER TABLE ONLY public.promocion ALTER COLUMN id_promocion SET DEFAULT nextval('public.promocion_id_promocion_seq'::regclass);
 E   ALTER TABLE public.promocion ALTER COLUMN id_promocion DROP DEFAULT;
       public          postgres    false    227    228    228            �           2604    17253    proveedor id    DEFAULT     l   ALTER TABLE ONLY public.proveedor ALTER COLUMN id SET DEFAULT nextval('public.proveedor_id_seq'::regclass);
 ;   ALTER TABLE public.proveedor ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    221    222            �           2604    17254    usuario id_usuario    DEFAULT     x   ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);
 A   ALTER TABLE public.usuario ALTER COLUMN id_usuario DROP DEFAULT;
       public          postgres    false    225    226    226            �          0    16558 
   aplicacion 
   TABLE DATA           �   COPY public.aplicacion ("tama¤o_mb", version, nombre, version_ios, tematica, id_proveedor, id_aplicacion, descripcion) FROM stdin;
    public          postgres    false    223   ��       �          0    16461    artista 
   TABLE DATA           k   COPY public.artista (id_artista, nombre_casa_disquera, fecha_inicio, fecha_fin, nom_artistico) FROM stdin;
    public          postgres    false    216   ��       �          0    16504    cancion 
   TABLE DATA           }   COPY public.cancion (id_cancion, id_artista, genero, nom_disco, duracion, fecha_lanz, nomb_cancion, un_vendidas) FROM stdin;
    public          postgres    false    219   g�       �          0    16455    casa_disquera 
   TABLE DATA           :   COPY public.casa_disquera (nombre, direccion) FROM stdin;
    public          postgres    false    214   S�       �          0    16621    compras 
   TABLE DATA           l   COPY public.compras (id_compra, id_producto, id_promo, id_usuario, fecha_compra, rating, monto) FROM stdin;
    public          postgres    false    231   ��       �          0    16527    dispositivo 
   TABLE DATA           a   COPY public.dispositivo (id_dispositivo, capacidad, generacion, version_ios, modelo) FROM stdin;
    public          postgres    false    220   ɘ       �          0    16579    dispositivo_com 
   TABLE DATA           E   COPY public.dispositivo_com (dispositivo, id_aplicacion) FROM stdin;
    public          postgres    false    224   b�       �          0    16610    paises 
   TABLE DATA           ;   COPY public.paises (nombre_pais, id_promocion) FROM stdin;
    public          postgres    false    229   ��       �          0    16475    producto 
   TABLE DATA           B   COPY public.producto (id_producto, puntuacion, costo) FROM stdin;
    public          postgres    false    218   3�       �          0    16601 	   promocion 
   TABLE DATA           _   COPY public.promocion (id_promocion, descuento, fecha_inicio, fecha_fin, duracion) FROM stdin;
    public          postgres    false    228   �       �          0    16544 	   proveedor 
   TABLE DATA           d   COPY public.proveedor (id, nombre, correo, direccion, fecha_afiliacion, tipo_proveedor) FROM stdin;
    public          postgres    false    222   ��       �          0    16590    usuario 
   TABLE DATA           v   COPY public.usuario (id_usuario, correo, nombre, apellido, num_tdc, fecha_venc, cod_vvt, direccion, pais) FROM stdin;
    public          postgres    false    226   ��       �           0    0    artista_id_artista_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.artista_id_artista_seq', 36, true);
          public          postgres    false    215            �           0    0    compras_id_compra_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.compras_id_compra_seq', 56, true);
          public          postgres    false    230            �           0    0    producto_id_producto_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.producto_id_producto_seq', 20, true);
          public          postgres    false    217            �           0    0    promocion_id_promocion_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.promocion_id_promocion_seq', 38, true);
          public          postgres    false    227            �           0    0    proveedor_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.proveedor_id_seq', 10, true);
          public          postgres    false    221            �           0    0    usuario_id_usuario_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 10, true);
          public          postgres    false    225            �           2606    16573    aplicacion aplicacion_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT aplicacion_pkey PRIMARY KEY (id_aplicacion);
 D   ALTER TABLE ONLY public.aplicacion DROP CONSTRAINT aplicacion_pkey;
       public            postgres    false    223            �           2606    16468    artista artista_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.artista
    ADD CONSTRAINT artista_pkey PRIMARY KEY (id_artista);
 >   ALTER TABLE ONLY public.artista DROP CONSTRAINT artista_pkey;
       public            postgres    false    216            �           2606    16513    cancion cancion_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT cancion_pkey PRIMARY KEY (id_cancion);
 >   ALTER TABLE ONLY public.cancion DROP CONSTRAINT cancion_pkey;
       public            postgres    false    219            �           2606    16459     casa_disquera casa_disquera_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.casa_disquera
    ADD CONSTRAINT casa_disquera_pkey PRIMARY KEY (nombre);
 J   ALTER TABLE ONLY public.casa_disquera DROP CONSTRAINT casa_disquera_pkey;
       public            postgres    false    214            �           2606    16629    compras compras_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_pkey PRIMARY KEY (id_compra, fecha_compra);
 >   ALTER TABLE ONLY public.compras DROP CONSTRAINT compras_pkey;
       public            postgres    false    231    231            �           2606    16583 $   dispositivo_com dispositivo_com_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.dispositivo_com
    ADD CONSTRAINT dispositivo_com_pkey PRIMARY KEY (dispositivo);
 N   ALTER TABLE ONLY public.dispositivo_com DROP CONSTRAINT dispositivo_com_pkey;
       public            postgres    false    224            �           2606    16534    dispositivo dispositivo_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.dispositivo
    ADD CONSTRAINT dispositivo_pkey PRIMARY KEY (id_dispositivo);
 F   ALTER TABLE ONLY public.dispositivo DROP CONSTRAINT dispositivo_pkey;
       public            postgres    false    220            �           2606    16614    paises paises_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.paises
    ADD CONSTRAINT paises_pkey PRIMARY KEY (nombre_pais);
 <   ALTER TABLE ONLY public.paises DROP CONSTRAINT paises_pkey;
       public            postgres    false    229            �           2606    16669    producto producto_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_pkey PRIMARY KEY (id_producto);
 @   ALTER TABLE ONLY public.producto DROP CONSTRAINT producto_pkey;
       public            postgres    false    218            �           2606    16608    promocion promocion_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.promocion
    ADD CONSTRAINT promocion_pkey PRIMARY KEY (id_promocion);
 B   ALTER TABLE ONLY public.promocion DROP CONSTRAINT promocion_pkey;
       public            postgres    false    228            �           2606    16553    proveedor proveedor_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.proveedor DROP CONSTRAINT proveedor_pkey;
       public            postgres    false    222            �           2606    16598    usuario usuario_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);
 >   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_pkey;
       public            postgres    false    226            �           2620    16696 *   compras actualizar_puntuacion_after_compra    TRIGGER     �   CREATE TRIGGER actualizar_puntuacion_after_compra AFTER INSERT OR UPDATE OF rating ON public.compras FOR EACH ROW WHEN ((new.rating IS NOT NULL)) EXECUTE FUNCTION public.actualizar_puntuacion_producto();
 C   DROP TRIGGER actualizar_puntuacion_after_compra ON public.compras;
       public          postgres    false    231    238    231    231            �           2620    16714 )   compras tr_crear_promocion_despues_compra    TRIGGER     �   CREATE TRIGGER tr_crear_promocion_despues_compra AFTER INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.fn_crear_promocion_usuario();
 B   DROP TRIGGER tr_crear_promocion_despues_compra ON public.compras;
       public          postgres    false    250    231            �           2620    16691    compras tr_promocion_compras    TRIGGER     �   CREATE TRIGGER tr_promocion_compras AFTER INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.fn_promocion_compras_usuario();
 5   DROP TRIGGER tr_promocion_compras ON public.compras;
       public          postgres    false    231    252            �           2620    16698 ,   compras validar_pais_promocion_before_insert    TRIGGER     �   CREATE TRIGGER validar_pais_promocion_before_insert BEFORE INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.validar_pais_promocion();
 E   DROP TRIGGER validar_pais_promocion_before_insert ON public.compras;
       public          postgres    false    231    251                        2620    16693 2   compras verificar_compatibilidad_ios_before_insert    TRIGGER     �   CREATE TRIGGER verificar_compatibilidad_ios_before_insert BEFORE INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.verificar_compatibilidad_ios();
 K   DROP TRIGGER verificar_compatibilidad_ios_before_insert ON public.compras;
       public          postgres    false    253    231            �           2606    16680 !   aplicacion fk_aplicacion_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT fk_aplicacion_producto FOREIGN KEY (id_aplicacion) REFERENCES public.producto(id_producto);
 K   ALTER TABLE ONLY public.aplicacion DROP CONSTRAINT fk_aplicacion_producto;
       public          postgres    false    218    223    3294            �           2606    16567 "   aplicacion fk_aplicacion_proveedor    FK CONSTRAINT     �   ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT fk_aplicacion_proveedor FOREIGN KEY (id_proveedor) REFERENCES public.proveedor(id);
 L   ALTER TABLE ONLY public.aplicacion DROP CONSTRAINT fk_aplicacion_proveedor;
       public          postgres    false    3300    222    223            �           2606    16469     artista fk_artista_casa_disquera    FK CONSTRAINT     �   ALTER TABLE ONLY public.artista
    ADD CONSTRAINT fk_artista_casa_disquera FOREIGN KEY (nombre_casa_disquera) REFERENCES public.casa_disquera(nombre) ON UPDATE CASCADE ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.artista DROP CONSTRAINT fk_artista_casa_disquera;
       public          postgres    false    3290    214    216            �           2606    16519    cancion fk_cancion_artista    FK CONSTRAINT     �   ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT fk_cancion_artista FOREIGN KEY (id_artista) REFERENCES public.artista(id_artista);
 D   ALTER TABLE ONLY public.cancion DROP CONSTRAINT fk_cancion_artista;
       public          postgres    false    3292    219    216            �           2606    16670    cancion fk_cancion_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT fk_cancion_producto FOREIGN KEY (id_cancion) REFERENCES public.producto(id_producto);
 E   ALTER TABLE ONLY public.cancion DROP CONSTRAINT fk_cancion_producto;
       public          postgres    false    218    219    3294            �           2606    16685    compras fk_compras_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_producto FOREIGN KEY (id_producto) REFERENCES public.producto(id_producto);
 E   ALTER TABLE ONLY public.compras DROP CONSTRAINT fk_compras_producto;
       public          postgres    false    231    3294    218            �           2606    16635    compras fk_compras_promo    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_promo FOREIGN KEY (id_promo) REFERENCES public.promocion(id_promocion);
 B   ALTER TABLE ONLY public.compras DROP CONSTRAINT fk_compras_promo;
       public          postgres    false    3308    228    231            �           2606    16640    compras fk_compras_usuario    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);
 D   ALTER TABLE ONLY public.compras DROP CONSTRAINT fk_compras_usuario;
       public          postgres    false    3306    226    231            �           2606    16584 -   dispositivo_com fk_dispositivo_com_aplicacion    FK CONSTRAINT     �   ALTER TABLE ONLY public.dispositivo_com
    ADD CONSTRAINT fk_dispositivo_com_aplicacion FOREIGN KEY (id_aplicacion) REFERENCES public.aplicacion(id_aplicacion);
 W   ALTER TABLE ONLY public.dispositivo_com DROP CONSTRAINT fk_dispositivo_com_aplicacion;
       public          postgres    false    3302    223    224            �           2606    16675 #   dispositivo fk_dispositivo_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.dispositivo
    ADD CONSTRAINT fk_dispositivo_producto FOREIGN KEY (id_dispositivo) REFERENCES public.producto(id_producto);
 M   ALTER TABLE ONLY public.dispositivo DROP CONSTRAINT fk_dispositivo_producto;
       public          postgres    false    218    220    3294            �           2606    16615    paises fk_key_promocion    FK CONSTRAINT     �   ALTER TABLE ONLY public.paises
    ADD CONSTRAINT fk_key_promocion FOREIGN KEY (id_promocion) REFERENCES public.promocion(id_promocion);
 A   ALTER TABLE ONLY public.paises DROP CONSTRAINT fk_key_promocion;
       public          postgres    false    228    229    3308            �   �  x�MR[n�0�&O��%9򧛤E'-�_�a�uJC�P�����d��+�������f��݂mN'�����K�H�Ď4E�r����t<�$�J�D��~�.���ō�*]�O����rV!�8)�DtF� ��xj���Of�J[�3Y1���������7���+�W��Uu�a�faJ�t�;K=��<��D��y���l�)�
Q�Ӑ�hs��]��P=�jH�bǜ�#�/S�`����*��g{q�j���=�y��^ ��ц��uR4���E�����l�m!k��
�'c'}x��k'�W�@���	��7�} b��0���.�m�fT�Y���W�y���+���-���m�H5��x%�/nf�W*�T!tw�)'��!�;�/SsYΙ�Gh}����٨2)����,y��zB�Ǝ�#��csg�N=�Yya� �xw}:�*5\������k�?39��I�ow���69      �   �  x����N�0��S�:��\�eia�Ki���|;e1O3�
O�S,\,Er����?�qd�����[iD�$,g|�S���K�4����n4��3�5Z���<��6�B�ڻ"r���B䱗e,�n� O<�"x%��:���ձS��0���n��z����V�H�y�g���GT�PJ6����U�l��4ZX�3Z�N��Ѣ�(PvH�����f����:I}�m����*ɕ���wCޘ;1>�nuWUM���7n��n����X�ڈV5
�膲�!9׷ �M+m�B�˧�h��k�c��5��{o`�h8b�#�sW��{O`X��
`{W�b�]�٪�f���m�oF�ƕ.�'0�&�8K`%pN����o��#t@�)���6UN�nw�_�� x����      �   �  x�m�Mn�0��O��RhH�.�_�E���nTU��f�X����@N�GI%#� g�=r�Q�3����w��{HAEJ�E���:����sx/�(����:b%�PO�9�C���5_v��)�1V��yq�*vD���F��H�`{j��ɶ�����J�
2�)R����q�J9$exdǽ�(Ȑam�����1{��1�3{AL�@��}K?�(혂�N���ؙ�4�T6"1<r�6�&G�������(��	=]nӾ�&���wK�Nf�͹p��";1S��ӕ4��	��ʢh+�_u�Ͱ��Z�c~1�ՖE8?�(t�Ը������T?X-�@�om�}WX5��!Ϭ����벏R|<��^U���׎�s+�盶'�-��&���k׼�p�/gA;t���k.U�ٝ ��鏾�������/�/Q@�_�B��ܴbs��}�����o�� �[�N�      �   ^  x�E�KR�0D��)t �r�|`�8��J
Vl�5��$;��8JN��Ě��n���<R�+�0)�`������R5RH>d��P&/�_��Q-I%���Nډ���q2�F�QXɳ4��1Y&I)��:|�i-�L�mS�	�nT���|�A佴���0# �TpN�"ف�`��A4,�P�|�}Ō�+�4JO��5��F�HR���{�U��e��o������& �|�N�����g�&B*��t
�ظ򉅩��Vhp�C���F�+*�/��p�B{�1���:��<�J��L�H՗m����U��e��+2��?O��5{j|�zn7\6��b����д�E      �   �   x�}��!D��^��H鿎�&��ₐ�fƌA���J��Ȁ)=�aW2rc5�����ՠ\!Cֺp0ŀ�����Jh�ͣRW��-w%�2e��w�e���̺�l�LN�L��2�l�i5�b������Av����3�R��0��ؠ���P��g%��6�X���b�y�@���Z�R�P�R�1��T��7�[ѰqFӮc\/0��-��-}�`�[��1����]ʄ����8�1���      �   �   x�Mλ
�P��z�)���s�I��F���4� ��;�.X_�)9�4)���a+��5�f�P�fZ�n0���Y��n%�{�X-��`����t�=�Zr:��?�Zv���O�ֹ��ޟX��]��=�\�t�s�k�D      �   2   x��I�0��4��{}s1�4b��������+w6���T���?���      �      x�s-.H<�$�Ӑ��Qì���|N#.Ǣ�Լ�̼DNc.����ܤ�DN��ԢC�9M��32sR9͸\�KS�8͹�KKRss9-��K�9-���s2ˀ��<Ks@,C.���<;F��� �v'      �   �   x�=N��0:�a���b{��?G!qz$��aَV�N�!�4�Lkk�%FҖg9�%�ɠ�I"Ytp���&�"��z�4�_r�5PNuB��"�o;Ԏ1:�ϝcs-�q�ꥣ��8Zm�T�׍ʗ��q�]�:)�:���	?����?�}? ~�,.�      �   �   x�}�K�0��s�x�q�������H,�~�F�hT�Uu_��T��z<B*.L�(��㑥Z�Mpږ�.��*.vZO�h��i{j�vH;�H�Ni���3t��v��x���#���>�b��U/�q�}���s��;��yr^��_@����jુ���jુ�f|5�_m$�/��qn��s�<8O��W)����      �   �   x�u�K
�0��ur�^��I��Um�.ܔ���D��G�d��X:�a��!-��5w��F���V�/�l�̙5��J����VD"dC���YkN��mrH%AK��d I�$-IZJ)E)�����@�P�h)�����u�h�N^��d�䡂;���
��ꋹ������˹��}�}E��\���K(�-����M����[�n��{������b�]@��v��f��9Ev!2޴_p�?W�      �     x�m�ώ�@�Ϟ��0��/����Th��ԋ����&4!�����}�}�>ImH�@kɇ��ß�lo:Y�F{���쬖�k`Ie��2!���( 
�tƓPA���O�`���k�E{��+sg]�ŠH [��7ׄY��HEPQ�\��~��'i*Ta�d0��o+�a�kE
L%��}��;�`5H�đ�́�2)�r��5v�w�ܛ�P��j���ޣܚF�B����Y���́�1���[��
6��k� ���)r(�[��g�[l���$QFL�P�*g�U��`F�0�>�nO�ix��k�b
R[5���mCu�?�a��@SM�T������;�z_��^И�Xr���cuR��I��V2��R0��T�J_۹C�!�u�h�T��� �w��W���DxE�)��n�Y*dV�"P��h��f�h��Z�&[��
�[�����@e(Q��[<Q�D����mú�m�_~����E���n�_�`�u��a ����|^[4X����W���8�҉�R���.�     