PGDMP      1            
    {            test    16.1    16.1 Z    J           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            K           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            L           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            M           1262    16799    test    DATABASE        CREATE DATABASE test WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Latin America.1252';
    DROP DATABASE test;
                postgres    false            g           1247    16828    generacion_disp    DOMAIN       CREATE DOMAIN public.generacion_disp AS character varying(10)
	CONSTRAINT generacion_disp_check CHECK (((VALUE)::text = ANY ((ARRAY['Gen1'::character varying, 'Gen2'::character varying, 'Gen3'::character varying, 'Gen4'::character varying, 'Gen5'::character varying])::text[])));
 $   DROP DOMAIN public.generacion_disp;
       public          postgres    false            k           1247    16831    genero_musical    DOMAIN     �  CREATE DOMAIN public.genero_musical AS character varying(50)
	CONSTRAINT genero_musical_check CHECK (((VALUE)::text = ANY ((ARRAY['Pop'::character varying, 'Balada'::character varying, 'Rock'::character varying, 'Jazz'::character varying, 'Electr¢nica'::character varying, 'Reggae'::character varying, 'Country'::character varying, 'Hip Hop'::character varying, 'Folk'::character varying, 'Clasica'::character varying, 'Salsa'::character varying, 'Merengue'::character varying, 'Bachata'::character varying, 'Vallenato'::character varying, 'Cumbia'::character varying, 'Tango'::character varying, 'Ranchera'::character varying, 'Bolero'::character varying, 'Samba'::character varying, 'Blues'::character varying, 'Rap'::character varying, 'Trap'::character varying, 'Reggaeton'::character varying, 'Metal'::character varying, 'Punk'::character varying, 'Indie'::character varying, 'Alternativa'::character varying, 'Grunge'::character varying, 'Gospel'::character varying, 'Disco'::character varying, 'House'::character varying, 'Techno'::character varying, 'Dubstep'::character varying, 'Drum and Bass'::character varying, 'Dance'::character varying, 'Funk'::character varying, 'Soul'::character varying, 'R&B'::character varying, 'Instrumental'::character varying, 'Ambiental'::character varying, 'New Age'::character varying, 'Infantil'::character varying, 'Blues'::character varying, 'Otro'::character varying])::text[])));
 #   DROP DOMAIN public.genero_musical;
       public          postgres    false            s           1247    16837    tematica_app    DOMAIN     y  CREATE DOMAIN public.tematica_app AS character varying(50)
	CONSTRAINT tematica_app_check CHECK (((VALUE)::text = ANY ((ARRAY['cocina'::character varying, 'lectura'::character varying, 'juegos'::character varying, 'educacion'::character varying, 'salud'::character varying, 'deporte'::character varying, 'musica'::character varying, 'noticias'::character varying])::text[])));
 !   DROP DOMAIN public.tematica_app;
       public          postgres    false            o           1247    16834    tipo_proveedor    DOMAIN     �   CREATE DOMAIN public.tipo_proveedor AS character varying(20)
	CONSTRAINT tipo_proveedor_check CHECK (((VALUE)::text = ANY ((ARRAY['desarrollador'::character varying, 'empresa'::character varying])::text[])));
 #   DROP DOMAIN public.tipo_proveedor;
       public          postgres    false            �            1255    16981     actualizar_puntuacion_producto()    FUNCTION     �  CREATE FUNCTION public.actualizar_puntuacion_producto() RETURNS trigger
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
       public          postgres    false            �            1255    16989    actualizar_unidades_vendidas()    FUNCTION       CREATE FUNCTION public.actualizar_unidades_vendidas() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    es_cancion BOOLEAN;
BEGIN
    -- Verificar si el id_producto corresponde a una canci¢n
    SELECT EXISTS(SELECT 1 FROM cancion WHERE id_cancion = NEW.id_producto)
    INTO es_cancion;

    -- Si es una canci¢n, entonces incrementar las unidades vendidas
    IF es_cancion THEN
        UPDATE cancion
        SET un_vendidas = un_vendidas + 1
        WHERE id_cancion = NEW.id_producto;
    END IF;

    RETURN NEW;
END;
$$;
 5   DROP FUNCTION public.actualizar_unidades_vendidas();
       public          postgres    false            �            1255    16983    fn_crear_promocion_usuario()    FUNCTION     �  CREATE FUNCTION public.fn_crear_promocion_usuario() RETURNS trigger
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
       public          postgres    false            �            1255    16985    validar_pais_promocion()    FUNCTION       CREATE FUNCTION public.validar_pais_promocion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$


DECLARE
    pais_usuario VARCHAR(50);
BEGIN
    -- Si no hay promoci›n asociada a la compra, no es necesario validar el pa­s
    IF NEW.id_promo IS NULL THEN
        RETURN NEW;
    END IF;


    -- Obtener el pa­s del usuario
    SELECT pais INTO pais_usuario
    FROM usuario
    WHERE id_usuario = NEW.id_usuario;


    -- Verificar si el pa­s del usuario coincide con los pa­ses de la promoci›n aplicada
    IF NOT EXISTS (
        SELECT 1
        FROM paises
        WHERE id_promocion = NEW.id_promo AND nombre_pais = pais_usuario
    ) THEN
        RAISE EXCEPTION 'La promocion no es valida en el pa­s del usuario.';
    END IF;


    RETURN NEW;
END;


$$;
 /   DROP FUNCTION public.validar_pais_promocion();
       public          postgres    false            �            1255    16987    verificar_compatibilidad_ios()    FUNCTION     C  CREATE FUNCTION public.verificar_compatibilidad_ios() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    version_dispositivo FLOAT;
    version_requerida_app FLOAT;
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

        -- Obtener la versi¢n iOS del dispositivo del usuario
        SELECT version_ios INTO version_dispositivo
        FROM dispositivo
        WHERE id_dispositivo = (SELECT id_dispositivo FROM usuario_dispositivo WHERE id_usuario = NEW.id_usuario);

        -- Verificar si la versi¢n del dispositivo es igual o superior a la versi¢n requerida por la aplicaci¢n
        IF version_dispositivo < version_requerida_app THEN
            RAISE EXCEPTION 'La versi¢n de iOS del dispositivo (%) no es compatible con la versi¢n requerida por la aplicaci¢n (%).', version_dispositivo, version_requerida_app;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;
 5   DROP FUNCTION public.verificar_compatibilidad_ios();
       public          postgres    false            �            1259    16884 
   aplicacion    TABLE     �  CREATE TABLE public.aplicacion (
    id_aplicacion integer NOT NULL,
    tamano_mb integer NOT NULL,
    version character varying(50) NOT NULL,
    nombre character varying(50) NOT NULL,
    version_ios double precision NOT NULL,
    tematica public.tematica_app,
    id_proveedor integer,
    descripcion character varying(50) NOT NULL,
    CONSTRAINT aplicacion_tamano_mb_check CHECK ((tamano_mb > 0))
);
    DROP TABLE public.aplicacion;
       public         heap    postgres    false    883            �            1259    16806    artista    TABLE     R  CREATE TABLE public.artista (
    id_artista integer NOT NULL,
    nombre_casa_disquera character varying(100) NOT NULL,
    fecha_inicio date DEFAULT CURRENT_DATE NOT NULL,
    fecha_fin date,
    nom_artistico character varying(100) NOT NULL,
    CONSTRAINT artista_check CHECK (((fecha_fin IS NULL) OR (fecha_fin >= fecha_inicio)))
);
    DROP TABLE public.artista;
       public         heap    postgres    false            �            1259    16805    artista_id_artista_seq    SEQUENCE     �   CREATE SEQUENCE public.artista_id_artista_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.artista_id_artista_seq;
       public          postgres    false    217            N           0    0    artista_id_artista_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.artista_id_artista_seq OWNED BY public.artista.id_artista;
          public          postgres    false    216            �            1259    16839    cancion    TABLE     �  CREATE TABLE public.cancion (
    id_cancion integer NOT NULL,
    id_artista integer NOT NULL,
    genero public.genero_musical NOT NULL,
    nom_disco character varying(50) NOT NULL,
    duracion integer NOT NULL,
    fecha_lanz date DEFAULT CURRENT_DATE NOT NULL,
    nomb_cancion character varying(50) NOT NULL,
    un_vendidas integer DEFAULT 0,
    CONSTRAINT cancion_duracion_check CHECK ((duracion > 0)),
    CONSTRAINT cancion_un_vendidas_check CHECK ((un_vendidas >= 0))
);
    DROP TABLE public.cancion;
       public         heap    postgres    false    875            �            1259    16800    casa_disquera    TABLE     �   CREATE TABLE public.casa_disquera (
    nombre character varying(100) NOT NULL,
    direccion character varying(255) NOT NULL
);
 !   DROP TABLE public.casa_disquera;
       public         heap    postgres    false            �            1259    16932    compras    TABLE     9  CREATE TABLE public.compras (
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
       public         heap    postgres    false            �            1259    16931    compras_id_compra_seq    SEQUENCE     �   CREATE SEQUENCE public.compras_id_compra_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.compras_id_compra_seq;
       public          postgres    false    230            O           0    0    compras_id_compra_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.compras_id_compra_seq OWNED BY public.compras.id_compra;
          public          postgres    false    229            �            1259    16860    dispositivo    TABLE     !  CREATE TABLE public.dispositivo (
    id_dispositivo integer NOT NULL,
    capacidad integer,
    generacion public.generacion_disp,
    version_ios double precision NOT NULL,
    modelo character varying(50) NOT NULL,
    CONSTRAINT dispositivo_capacidad_check CHECK ((capacidad > 0))
);
    DROP TABLE public.dispositivo;
       public         heap    postgres    false    871            �            1259    16902    dispositivo_com    TABLE     |   CREATE TABLE public.dispositivo_com (
    dispositivo character varying(50) NOT NULL,
    id_aplicacion integer NOT NULL
);
 #   DROP TABLE public.dispositivo_com;
       public         heap    postgres    false            �            1259    16956    paises    TABLE     i   CREATE TABLE public.paises (
    nombre_pais character varying(50) NOT NULL,
    id_promocion integer
);
    DROP TABLE public.paises;
       public         heap    postgres    false            �            1259    16819    producto    TABLE     G  CREATE TABLE public.producto (
    id_producto integer NOT NULL,
    puntuacion double precision DEFAULT 0,
    costo integer NOT NULL,
    CONSTRAINT producto_costo_check CHECK ((costo > 0)),
    CONSTRAINT producto_puntuacion_check CHECK (((puntuacion >= (0)::double precision) AND (puntuacion <= (5)::double precision)))
);
    DROP TABLE public.producto;
       public         heap    postgres    false            �            1259    16923 	   promocion    TABLE     W  CREATE TABLE public.promocion (
    id_promocion integer NOT NULL,
    descuento integer NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date NOT NULL,
    duracion integer,
    CONSTRAINT promocion_check CHECK ((fecha_fin > fecha_inicio)),
    CONSTRAINT promocion_descuento_check CHECK (((descuento >= 0) AND (descuento <= 100)))
);
    DROP TABLE public.promocion;
       public         heap    postgres    false            �            1259    16922    promocion_id_promocion_seq    SEQUENCE     �   CREATE SEQUENCE public.promocion_id_promocion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.promocion_id_promocion_seq;
       public          postgres    false    228            P           0    0    promocion_id_promocion_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.promocion_id_promocion_seq OWNED BY public.promocion.id_promocion;
          public          postgres    false    227            �            1259    16874 	   proveedor    TABLE     y  CREATE TABLE public.proveedor (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    correo character varying(50) NOT NULL,
    direccion character varying(255) NOT NULL,
    fecha_afiliacion date DEFAULT CURRENT_DATE,
    tipo_proveedor public.tipo_proveedor NOT NULL,
    CONSTRAINT proveedor_correo_check CHECK (((correo)::text ~ '^.+@.+\..+$'::text))
);
    DROP TABLE public.proveedor;
       public         heap    postgres    false    879            �            1259    16873    proveedor_id_seq    SEQUENCE     �   CREATE SEQUENCE public.proveedor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.proveedor_id_seq;
       public          postgres    false    222            Q           0    0    proveedor_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.proveedor_id_seq OWNED BY public.proveedor.id;
          public          postgres    false    221            �            1259    16913    usuario    TABLE     �  CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    correo character varying(50) NOT NULL,
    nombre character varying(50) NOT NULL,
    apellido character varying(50) NOT NULL,
    num_tdc character varying(16) NOT NULL,
    fecha_venc date NOT NULL,
    cod_vvt character varying(5) NOT NULL,
    direccion character varying(255) NOT NULL,
    pais character varying(50) NOT NULL,
    CONSTRAINT usuario_cod_vvt_check CHECK (((cod_vvt)::text ~ '^\d+$'::text)),
    CONSTRAINT usuario_correo_check CHECK (((correo)::text ~ '^.+@.+\..+$'::text)),
    CONSTRAINT usuario_num_tdc_check CHECK (((num_tdc)::text ~ '^\d+$'::text))
);
    DROP TABLE public.usuario;
       public         heap    postgres    false            �            1259    16966    usuario_dispositivo    TABLE     r   CREATE TABLE public.usuario_dispositivo (
    id_usuario integer NOT NULL,
    id_dispositivo integer NOT NULL
);
 '   DROP TABLE public.usuario_dispositivo;
       public         heap    postgres    false            �            1259    16912    usuario_id_usuario_seq    SEQUENCE     �   CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.usuario_id_usuario_seq;
       public          postgres    false    226            R           0    0    usuario_id_usuario_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;
          public          postgres    false    225            c           2604    16809    artista id_artista    DEFAULT     x   ALTER TABLE ONLY public.artista ALTER COLUMN id_artista SET DEFAULT nextval('public.artista_id_artista_seq'::regclass);
 A   ALTER TABLE public.artista ALTER COLUMN id_artista DROP DEFAULT;
       public          postgres    false    217    216    217            l           2604    16935    compras id_compra    DEFAULT     v   ALTER TABLE ONLY public.compras ALTER COLUMN id_compra SET DEFAULT nextval('public.compras_id_compra_seq'::regclass);
 @   ALTER TABLE public.compras ALTER COLUMN id_compra DROP DEFAULT;
       public          postgres    false    229    230    230            k           2604    16926    promocion id_promocion    DEFAULT     �   ALTER TABLE ONLY public.promocion ALTER COLUMN id_promocion SET DEFAULT nextval('public.promocion_id_promocion_seq'::regclass);
 E   ALTER TABLE public.promocion ALTER COLUMN id_promocion DROP DEFAULT;
       public          postgres    false    228    227    228            h           2604    16877    proveedor id    DEFAULT     l   ALTER TABLE ONLY public.proveedor ALTER COLUMN id SET DEFAULT nextval('public.proveedor_id_seq'::regclass);
 ;   ALTER TABLE public.proveedor ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    221    222    222            j           2604    16916    usuario id_usuario    DEFAULT     x   ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);
 A   ALTER TABLE public.usuario ALTER COLUMN id_usuario DROP DEFAULT;
       public          postgres    false    225    226    226            >          0    16884 
   aplicacion 
   TABLE DATA           �   COPY public.aplicacion (id_aplicacion, tamano_mb, version, nombre, version_ios, tematica, id_proveedor, descripcion) FROM stdin;
    public          postgres    false    223   �       8          0    16806    artista 
   TABLE DATA           k   COPY public.artista (id_artista, nombre_casa_disquera, fecha_inicio, fecha_fin, nom_artistico) FROM stdin;
    public          postgres    false    217   �       :          0    16839    cancion 
   TABLE DATA           }   COPY public.cancion (id_cancion, id_artista, genero, nom_disco, duracion, fecha_lanz, nomb_cancion, un_vendidas) FROM stdin;
    public          postgres    false    219   G�       6          0    16800    casa_disquera 
   TABLE DATA           :   COPY public.casa_disquera (nombre, direccion) FROM stdin;
    public          postgres    false    215   R�       E          0    16932    compras 
   TABLE DATA           l   COPY public.compras (id_compra, id_producto, id_promo, id_usuario, fecha_compra, rating, monto) FROM stdin;
    public          postgres    false    230   ��       ;          0    16860    dispositivo 
   TABLE DATA           a   COPY public.dispositivo (id_dispositivo, capacidad, generacion, version_ios, modelo) FROM stdin;
    public          postgres    false    220   g�       ?          0    16902    dispositivo_com 
   TABLE DATA           E   COPY public.dispositivo_com (dispositivo, id_aplicacion) FROM stdin;
    public          postgres    false    224   ��       F          0    16956    paises 
   TABLE DATA           ;   COPY public.paises (nombre_pais, id_promocion) FROM stdin;
    public          postgres    false    231   W�       9          0    16819    producto 
   TABLE DATA           B   COPY public.producto (id_producto, puntuacion, costo) FROM stdin;
    public          postgres    false    218   ǒ       C          0    16923 	   promocion 
   TABLE DATA           _   COPY public.promocion (id_promocion, descuento, fecha_inicio, fecha_fin, duracion) FROM stdin;
    public          postgres    false    228   ��       =          0    16874 	   proveedor 
   TABLE DATA           d   COPY public.proveedor (id, nombre, correo, direccion, fecha_afiliacion, tipo_proveedor) FROM stdin;
    public          postgres    false    222    �       A          0    16913    usuario 
   TABLE DATA           v   COPY public.usuario (id_usuario, correo, nombre, apellido, num_tdc, fecha_venc, cod_vvt, direccion, pais) FROM stdin;
    public          postgres    false    226   �       G          0    16966    usuario_dispositivo 
   TABLE DATA           I   COPY public.usuario_dispositivo (id_usuario, id_dispositivo) FROM stdin;
    public          postgres    false    232   �       S           0    0    artista_id_artista_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.artista_id_artista_seq', 18, true);
          public          postgres    false    216            T           0    0    compras_id_compra_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.compras_id_compra_seq', 26, true);
          public          postgres    false    229            U           0    0    promocion_id_promocion_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.promocion_id_promocion_seq', 12, true);
          public          postgres    false    227            V           0    0    proveedor_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.proveedor_id_seq', 10, true);
          public          postgres    false    221            W           0    0    usuario_id_usuario_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 10, true);
          public          postgres    false    225            �           2606    16891    aplicacion aplicacion_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT aplicacion_pkey PRIMARY KEY (id_aplicacion);
 D   ALTER TABLE ONLY public.aplicacion DROP CONSTRAINT aplicacion_pkey;
       public            postgres    false    223            ~           2606    16813    artista artista_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.artista
    ADD CONSTRAINT artista_pkey PRIMARY KEY (id_artista);
 >   ALTER TABLE ONLY public.artista DROP CONSTRAINT artista_pkey;
       public            postgres    false    217            �           2606    16849    cancion cancion_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT cancion_pkey PRIMARY KEY (id_cancion);
 >   ALTER TABLE ONLY public.cancion DROP CONSTRAINT cancion_pkey;
       public            postgres    false    219            |           2606    16804     casa_disquera casa_disquera_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.casa_disquera
    ADD CONSTRAINT casa_disquera_pkey PRIMARY KEY (nombre);
 J   ALTER TABLE ONLY public.casa_disquera DROP CONSTRAINT casa_disquera_pkey;
       public            postgres    false    215            �           2606    16940    compras compras_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT compras_pkey PRIMARY KEY (id_compra);
 >   ALTER TABLE ONLY public.compras DROP CONSTRAINT compras_pkey;
       public            postgres    false    230            �           2606    16906 $   dispositivo_com dispositivo_com_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.dispositivo_com
    ADD CONSTRAINT dispositivo_com_pkey PRIMARY KEY (dispositivo);
 N   ALTER TABLE ONLY public.dispositivo_com DROP CONSTRAINT dispositivo_com_pkey;
       public            postgres    false    224            �           2606    16867    dispositivo dispositivo_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.dispositivo
    ADD CONSTRAINT dispositivo_pkey PRIMARY KEY (id_dispositivo);
 F   ALTER TABLE ONLY public.dispositivo DROP CONSTRAINT dispositivo_pkey;
       public            postgres    false    220            �           2606    16960    paises paises_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.paises
    ADD CONSTRAINT paises_pkey PRIMARY KEY (nombre_pais);
 <   ALTER TABLE ONLY public.paises DROP CONSTRAINT paises_pkey;
       public            postgres    false    231            �           2606    16826    producto producto_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_pkey PRIMARY KEY (id_producto);
 @   ALTER TABLE ONLY public.producto DROP CONSTRAINT producto_pkey;
       public            postgres    false    218            �           2606    16930    promocion promocion_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.promocion
    ADD CONSTRAINT promocion_pkey PRIMARY KEY (id_promocion);
 B   ALTER TABLE ONLY public.promocion DROP CONSTRAINT promocion_pkey;
       public            postgres    false    228            �           2606    16883    proveedor proveedor_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.proveedor DROP CONSTRAINT proveedor_pkey;
       public            postgres    false    222            �           2606    16970 ,   usuario_dispositivo usuario_dispositivo_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.usuario_dispositivo
    ADD CONSTRAINT usuario_dispositivo_pkey PRIMARY KEY (id_usuario, id_dispositivo);
 V   ALTER TABLE ONLY public.usuario_dispositivo DROP CONSTRAINT usuario_dispositivo_pkey;
       public            postgres    false    232    232            �           2606    16921    usuario usuario_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);
 >   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_pkey;
       public            postgres    false    226            �           2620    16982 *   compras actualizar_puntuacion_after_compra    TRIGGER     �   CREATE TRIGGER actualizar_puntuacion_after_compra AFTER INSERT OR UPDATE OF rating ON public.compras FOR EACH ROW WHEN ((new.rating IS NOT NULL)) EXECUTE FUNCTION public.actualizar_puntuacion_producto();
 C   DROP TRIGGER actualizar_puntuacion_after_compra ON public.compras;
       public          postgres    false    230    230    230    233            �           2620    16990    compras after_compra_update    TRIGGER     �   CREATE TRIGGER after_compra_update AFTER INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.actualizar_unidades_vendidas();
 4   DROP TRIGGER after_compra_update ON public.compras;
       public          postgres    false    230    248            �           2620    16984 )   compras tr_crear_promocion_despues_compra    TRIGGER     �   CREATE TRIGGER tr_crear_promocion_despues_compra BEFORE INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.fn_crear_promocion_usuario();
 B   DROP TRIGGER tr_crear_promocion_despues_compra ON public.compras;
       public          postgres    false    234    230            �           2620    16986 ,   compras validar_pais_promocion_before_insert    TRIGGER     �   CREATE TRIGGER validar_pais_promocion_before_insert BEFORE INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.validar_pais_promocion();
 E   DROP TRIGGER validar_pais_promocion_before_insert ON public.compras;
       public          postgres    false    235    230            �           2620    16988 2   compras verificar_compatibilidad_ios_before_insert    TRIGGER     �   CREATE TRIGGER verificar_compatibilidad_ios_before_insert BEFORE INSERT ON public.compras FOR EACH ROW EXECUTE FUNCTION public.verificar_compatibilidad_ios();
 K   DROP TRIGGER verificar_compatibilidad_ios_before_insert ON public.compras;
       public          postgres    false    247    230            �           2606    16892 !   aplicacion fk_aplicacion_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT fk_aplicacion_producto FOREIGN KEY (id_aplicacion) REFERENCES public.producto(id_producto);
 K   ALTER TABLE ONLY public.aplicacion DROP CONSTRAINT fk_aplicacion_producto;
       public          postgres    false    4736    223    218            �           2606    16897 "   aplicacion fk_aplicacion_proveedor    FK CONSTRAINT     �   ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT fk_aplicacion_proveedor FOREIGN KEY (id_proveedor) REFERENCES public.proveedor(id);
 L   ALTER TABLE ONLY public.aplicacion DROP CONSTRAINT fk_aplicacion_proveedor;
       public          postgres    false    4742    223    222            �           2606    16814     artista fk_artista_casa_disquera    FK CONSTRAINT     �   ALTER TABLE ONLY public.artista
    ADD CONSTRAINT fk_artista_casa_disquera FOREIGN KEY (nombre_casa_disquera) REFERENCES public.casa_disquera(nombre) ON UPDATE CASCADE ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.artista DROP CONSTRAINT fk_artista_casa_disquera;
       public          postgres    false    4732    217    215            �           2606    16855    cancion fk_cancion_artista    FK CONSTRAINT     �   ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT fk_cancion_artista FOREIGN KEY (id_artista) REFERENCES public.artista(id_artista);
 D   ALTER TABLE ONLY public.cancion DROP CONSTRAINT fk_cancion_artista;
       public          postgres    false    219    217    4734            �           2606    16850    cancion fk_cancion_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT fk_cancion_producto FOREIGN KEY (id_cancion) REFERENCES public.producto(id_producto);
 E   ALTER TABLE ONLY public.cancion DROP CONSTRAINT fk_cancion_producto;
       public          postgres    false    218    4736    219            �           2606    16941    compras fk_compras_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_producto FOREIGN KEY (id_producto) REFERENCES public.producto(id_producto);
 E   ALTER TABLE ONLY public.compras DROP CONSTRAINT fk_compras_producto;
       public          postgres    false    4736    218    230            �           2606    16946    compras fk_compras_promo    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_promo FOREIGN KEY (id_promo) REFERENCES public.promocion(id_promocion);
 B   ALTER TABLE ONLY public.compras DROP CONSTRAINT fk_compras_promo;
       public          postgres    false    228    230    4750            �           2606    16951    compras fk_compras_usuario    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);
 D   ALTER TABLE ONLY public.compras DROP CONSTRAINT fk_compras_usuario;
       public          postgres    false    230    4748    226            �           2606    16907 -   dispositivo_com fk_dispositivo_com_aplicacion    FK CONSTRAINT     �   ALTER TABLE ONLY public.dispositivo_com
    ADD CONSTRAINT fk_dispositivo_com_aplicacion FOREIGN KEY (id_aplicacion) REFERENCES public.aplicacion(id_aplicacion);
 W   ALTER TABLE ONLY public.dispositivo_com DROP CONSTRAINT fk_dispositivo_com_aplicacion;
       public          postgres    false    223    224    4744            �           2606    16868 #   dispositivo fk_dispositivo_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.dispositivo
    ADD CONSTRAINT fk_dispositivo_producto FOREIGN KEY (id_dispositivo) REFERENCES public.producto(id_producto);
 M   ALTER TABLE ONLY public.dispositivo DROP CONSTRAINT fk_dispositivo_producto;
       public          postgres    false    4736    220    218            �           2606    16961    paises fk_key_promocion    FK CONSTRAINT     �   ALTER TABLE ONLY public.paises
    ADD CONSTRAINT fk_key_promocion FOREIGN KEY (id_promocion) REFERENCES public.promocion(id_promocion);
 A   ALTER TABLE ONLY public.paises DROP CONSTRAINT fk_key_promocion;
       public          postgres    false    228    4750    231            �           2606    16976 ;   usuario_dispositivo usuario_dispositivo_id_dispositivo_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuario_dispositivo
    ADD CONSTRAINT usuario_dispositivo_id_dispositivo_fkey FOREIGN KEY (id_dispositivo) REFERENCES public.dispositivo(id_dispositivo);
 e   ALTER TABLE ONLY public.usuario_dispositivo DROP CONSTRAINT usuario_dispositivo_id_dispositivo_fkey;
       public          postgres    false    220    4740    232            �           2606    16971 7   usuario_dispositivo usuario_dispositivo_id_usuario_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuario_dispositivo
    ADD CONSTRAINT usuario_dispositivo_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);
 a   ALTER TABLE ONLY public.usuario_dispositivo DROP CONSTRAINT usuario_dispositivo_id_usuario_fkey;
       public          postgres    false    4748    232    226            >   �  x�]R�n�0<���_ ���:�NS�����@/q%��H����$A�D_�e��F�%wvfv��l@�|��L�ǘ(�l��q�e��p�%�Ŀ>�ƙdN�R
TӀ����>Ǹ@:w��@��)��nS�C����t�� �QK�5�m��rmְ(:?N8�����$G1��B�m�ZP,�e{��a@.^Zؓ6���ON���O�lD�V U����l�_{L���ku�~7��}#&�d:�	��d�g�5�M�z���=�W,育�w�'�
�";s*�YNdE)�q~:���m�b��@�E�
��
j�lz�!�(&�"�D�ơ�G>���c�Z���TY���~�[��.�l�@��)o�|/&d�ɳ2a�+\-�j�m1K�'��7�L.Yq��0��5e[�b��B�yc�T+6� la���5R .���U�n^�U:�λ���uÇL�)�&�G%�����C��Կ���G���QWU����      8   3  x����j1���S�X����G�R�w��%�Ft'6�*���V(��������H�Z�i��u��l��#!F��o��XҺwFa���*/���5Ʀv�J+�i1��>٦��<j����=�b���dXӻ�M������*�������4�j�^]���,Sؙ'9P<��M�J�ΰ��{����t�5�{� �PY6�*�q�}$��;�;|�Z�gK����[۶��P���b��ƒ��QK'�PX���8X$j��!��l �P�X���
�_V��ʘm:��l�,f�`��l+��      :   �  x���͎�0��ӧ�X;I��BU!-�Z>.\fSS�M��vV�'���'��0����R!!U�R�7�G��+sϵ���GR$ �^q!s(�ԪZYH&$�M}|ݢQ.�2�'�p�p٩�a&�^��|���8��K՘��;ᦣ;�T�hT���G�k�?V�<f �_k�7�ѭ�����:$�!���,r��4xi���sH�Af?�6��-�ζ�!��N�as�4V�)�S�� ��X:p�xE��m�`�R��~õ1���O��M�����g �l�oq�/���V)��������zk��%��[�����i缴u89�L{�d]6]x_�p�g��'e�|�%,���.�Y�2�G[��܀�Ʋ�U"R��{=ᆒEV2�s�GqC��*����Vc�~[�Y���47q�7԰�C�bԦ��j
]5<lB��-����G�$����aF����+ǣ+es����l�%�,s��M'�M&�_�S7w      6   6  x�M�MN�0���)� J�a�Њ.��Ҩ+6ƞR����N�\��p2'��,~�y�y'lM��%Y��d:����>��qZ³��P��h1�Firl�XBa�bũ�J��cE��\��:�z|������`��
y&���Ax���5�� �@� Yժ^,Q�l�`k<Z/���x6M�q�{j���a��NtC
6Kg���BF��>�*��s@9��3�dBq�K`�t#CcQ[b}!(��gǖ����:�
�'���?�t�X��!Go�B�v|��W�V��m�E)�Ϸ��?��y��8�]a��      E   �   x�}���0E��.��b�N�	���+VTU�#��` B� C;K�Ab|07�D$D#�KB%(E��K�^E�$Or�.�ʘ�%����0
�<��1<��K����[g�uX�_c�tX�Jl����-�tl|Ƥe�?�ˋkھ��ŲY6����>7�cmRX����X�X��O�e۲���7|��9Zk_��[      ;   �   x�]�;�Pk�)8�S��C(	� 7�$"��b���Κ]k��Vd�?fy,���쎠
�wnG	>�:Z��,��O�N��E؂�av�ص�`����{/��o�k�&��>�8i$W��\����(w�Ms�3X��:E      ?   I   x���OI��Wp�42�򅰝8��`lgN#cۅ���v�42���9��alN#ۓ�����46������ ��      F   `   x����0��ޏ!�":6&0NM7��Ф>I�D��s�whx��%���4pdx�ľ�或�X޲g�E��qX�7\8j��J���E9	Mͩ"�f�{      9   �   x�U�˵�0C�PL�'�L�u�ļ��F��X&<��%e��b=�Soi���(��U����F$��db�Y,\4K�����a+��"��K#�ϳ��A��s��{h��P��R��b�oi�:��y<amZ�6�QV�g����Ѥ^��'ţ5��X]���I������W���.w�ò7�      C   �   x�}�K�0E�1���?{���G3����DI@RQk�s�h V��J�j�E:��=VV��vҴ�jov�f'K�U=� K;����z�Yu�]�Ӯ�+�&O���x��r��o��<�;�Y��"�="      =   �  x��R]S�0|v~�~@������S�`����7w;�8����2�r���j%�*������+k�X�e�7���.ۉ�(!��C�)�+���Rk|EV�'y~RT��� �B\�@m[���UV(�d7� 7����Z�N�m���q܃}1�S�t�j-[�R\c'�Մ����L����������j<g}z���{��-��Y��GY��a�q�L;�=jm7��,���0S��D�[�� �&E+���S*q���%�5�𞇡�M;WxiAh"sS�6�����[��e���s(2B�,]f%0�b��t���Y�p��+��6o`L8[�x�;gwNv����Oţr~��,x����)�<��*8��M
��O��,�3As#�i?���b6�~�c�EW�
���z&��)晸 S�����_gk`6�A�ݏE�$�f�6�      A   �  x�]�Qo�0���?`�l�x[h�F�t��^���:v�����vؤ��:�c�{pF�X��g��mg�\OA��@�l�߭�>~���5�D��YP�E9|Z�cpW?ʂH8�Ʋ��C3E�(Ì����
IE1+��δ��]]�-�H2h�kd�u�τ�:�3��v{AeA�gq��p4u
8�w]9����b�w�X�k�Q77��<���R��U����`�x�F[$9`Ӫ���xU(�����,>)�r�j�)`�O��;}t�ն��Ϊ~��9�d��E�甯���K�0�0�������`�W��z�$�e4����	Yܛ�+�j_5)�}
x�-YC�F+F<�����!f!ٸ@|C%�˕����q����9�m��j|�5;��4Nr�_����/A��J}���T��kRJم?	�qF��]��:I9&�рYH>V&8�y|h����¾*�RFq�6	�/F�֑�      G      x������ � �     