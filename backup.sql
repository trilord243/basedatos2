PGDMP                  
    {            proyecto_fase2    15.5    16.1 Q    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16454    proyecto_fase2    DATABASE     �   CREATE DATABASE proyecto_fase2 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Latin America.1252';
    DROP DATABASE proyecto_fase2;
                postgres    false            g           1247    16525    generacion_disp    DOMAIN       CREATE DOMAIN public.generacion_disp AS character varying(10)
	CONSTRAINT generacion_disp_check CHECK (((VALUE)::text = ANY ((ARRAY['Gen1'::character varying, 'Gen2'::character varying, 'Gen3'::character varying, 'Gen4'::character varying, 'Gen5'::character varying])::text[])));
 $   DROP DOMAIN public.generacion_disp;
       public          postgres    false            `           1247    16485    genero_musical    DOMAIN     �  CREATE DOMAIN public.genero_musical AS character varying(50)
	CONSTRAINT genero_musical_check CHECK (((VALUE)::text = ANY ((ARRAY['Rock'::character varying, 'Pop'::character varying, 'Jazz'::character varying, 'Cl sica'::character varying, 'Electr¢nica'::character varying, 'Reggae'::character varying, 'Hip Hop'::character varying, 'Blues'::character varying, 'Country'::character varying, 'Folk'::character varying])::text[])));
 #   DROP DOMAIN public.genero_musical;
       public          postgres    false            u           1247    16555    tematica_app    DOMAIN     y  CREATE DOMAIN public.tematica_app AS character varying(50)
	CONSTRAINT tematica_app_check CHECK (((VALUE)::text = ANY ((ARRAY['cocina'::character varying, 'lectura'::character varying, 'juegos'::character varying, 'educacion'::character varying, 'salud'::character varying, 'deporte'::character varying, 'musica'::character varying, 'noticias'::character varying])::text[])));
 !   DROP DOMAIN public.tematica_app;
       public          postgres    false            n           1247    16541    tipo_proveedor    DOMAIN     �   CREATE DOMAIN public.tipo_proveedor AS character varying(20)
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
       public         heap    postgres    false    885            �            1259    16461    artista    TABLE     R  CREATE TABLE public.artista (
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
       public         heap    postgres    false    864            �            1259    16455    casa_disquera    TABLE     �   CREATE TABLE public.casa_disquera (
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
          public          postgres    false    230            �            1259    16527    dispositivo    TABLE     &  CREATE TABLE public.dispositivo (
    id_dispositivo integer NOT NULL,
    capacidad integer,
    generacion public.generacion_disp,
    version_ios character varying(15) NOT NULL,
    modelo character varying(50) NOT NULL,
    CONSTRAINT dispositivo_capacidad_check CHECK ((capacidad > 0))
);
    DROP TABLE public.dispositivo;
       public         heap    postgres    false    871            �            1259    16579    dispositivo_com    TABLE     |   CREATE TABLE public.dispositivo_com (
    dispositivo character varying(50) NOT NULL,
    id_aplicacion integer NOT NULL
);
 #   DROP TABLE public.dispositivo_com;
       public         heap    postgres    false            �            1259    16610    paises    TABLE     i   CREATE TABLE public.paises (
    nombre_pais character varying(50) NOT NULL,
    id_promocion integer
);
    DROP TABLE public.paises;
       public         heap    postgres    false            �            1259    16475    producto    TABLE       CREATE TABLE public.producto (
    id_producto integer NOT NULL,
    puntuacion integer DEFAULT 0,
    costo integer NOT NULL,
    CONSTRAINT producto_costo_check CHECK ((costo > 0)),
    CONSTRAINT producto_puntuacion_check CHECK (((puntuacion >= 0) AND (puntuacion <= 5)))
);
    DROP TABLE public.producto;
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
          public          postgres    false    227            �            1259    16544 	   proveedor    TABLE     p  CREATE TABLE public.proveedor (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    correo character varying(50) NOT NULL,
    direccion character varying(255) NOT NULL,
    fecha_afiliacion date DEFAULT CURRENT_DATE,
    tipo_proveedor public.tipo_proveedor,
    CONSTRAINT proveedor_correo_check CHECK (((correo)::text ~ '^.+@.+\..+$'::text))
);
    DROP TABLE public.proveedor;
       public         heap    postgres    false    878            �            1259    16543    proveedor_id_seq    SEQUENCE     �   CREATE SEQUENCE public.proveedor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.proveedor_id_seq;
       public          postgres    false    222            �           0    0    proveedor_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.proveedor_id_seq OWNED BY public.proveedor.id;
          public          postgres    false    221            �            1259    16590    usuario    TABLE     \  CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    correo character varying(50) NOT NULL,
    nombre character varying(50) NOT NULL,
    apellido character varying(50) NOT NULL,
    num_tdc character varying(16) NOT NULL,
    fecha_venc date NOT NULL,
    cod_vvt character varying(5) NOT NULL,
    direccion character varying(255) NOT NULL,
    CONSTRAINT usuario_cod_vvt_check CHECK (((cod_vvt)::text ~ '^\d+$'::text)),
    CONSTRAINT usuario_correo_check CHECK (((correo)::text ~ '^.+@.+\..+$'::text)),
    CONSTRAINT usuario_num_tdc_check CHECK (((num_tdc)::text ~ '^\d+$'::text))
);
    DROP TABLE public.usuario;
       public         heap    postgres    false            �            1259    16589    usuario_id_usuario_seq    SEQUENCE     �   CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.usuario_id_usuario_seq;
       public          postgres    false    226            �           0    0    usuario_id_usuario_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;
          public          postgres    false    225            �           2604    16464    artista id_artista    DEFAULT     x   ALTER TABLE ONLY public.artista ALTER COLUMN id_artista SET DEFAULT nextval('public.artista_id_artista_seq'::regclass);
 A   ALTER TABLE public.artista ALTER COLUMN id_artista DROP DEFAULT;
       public          postgres    false    215    216    216            �           2604    16624    compras id_compra    DEFAULT     v   ALTER TABLE ONLY public.compras ALTER COLUMN id_compra SET DEFAULT nextval('public.compras_id_compra_seq'::regclass);
 @   ALTER TABLE public.compras ALTER COLUMN id_compra DROP DEFAULT;
       public          postgres    false    231    230    231            �           2604    16667    producto id_producto    DEFAULT     |   ALTER TABLE ONLY public.producto ALTER COLUMN id_producto SET DEFAULT nextval('public.producto_id_producto_seq'::regclass);
 C   ALTER TABLE public.producto ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    218    217    218            �           2604    16604    promocion id_promocion    DEFAULT     �   ALTER TABLE ONLY public.promocion ALTER COLUMN id_promocion SET DEFAULT nextval('public.promocion_id_promocion_seq'::regclass);
 E   ALTER TABLE public.promocion ALTER COLUMN id_promocion DROP DEFAULT;
       public          postgres    false    227    228    228            �           2604    16547    proveedor id    DEFAULT     l   ALTER TABLE ONLY public.proveedor ALTER COLUMN id SET DEFAULT nextval('public.proveedor_id_seq'::regclass);
 ;   ALTER TABLE public.proveedor ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    221    222    222            �           2604    16593    usuario id_usuario    DEFAULT     x   ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);
 A   ALTER TABLE public.usuario ALTER COLUMN id_usuario DROP DEFAULT;
       public          postgres    false    225    226    226            {          0    16558 
   aplicacion 
   TABLE DATA           �   COPY public.aplicacion ("tama¤o_mb", version, nombre, version_ios, tematica, id_proveedor, id_aplicacion, descripcion) FROM stdin;
    public          postgres    false    223   -k       t          0    16461    artista 
   TABLE DATA           k   COPY public.artista (id_artista, nombre_casa_disquera, fecha_inicio, fecha_fin, nom_artistico) FROM stdin;
    public          postgres    false    216   �l       w          0    16504    cancion 
   TABLE DATA           }   COPY public.cancion (id_cancion, id_artista, genero, nom_disco, duracion, fecha_lanz, nomb_cancion, un_vendidas) FROM stdin;
    public          postgres    false    219   >m       r          0    16455    casa_disquera 
   TABLE DATA           :   COPY public.casa_disquera (nombre, direccion) FROM stdin;
    public          postgres    false    214   Ln       �          0    16621    compras 
   TABLE DATA           l   COPY public.compras (id_compra, id_producto, id_promo, id_usuario, fecha_compra, rating, monto) FROM stdin;
    public          postgres    false    231   o       x          0    16527    dispositivo 
   TABLE DATA           a   COPY public.dispositivo (id_dispositivo, capacidad, generacion, version_ios, modelo) FROM stdin;
    public          postgres    false    220   ,o       |          0    16579    dispositivo_com 
   TABLE DATA           E   COPY public.dispositivo_com (dispositivo, id_aplicacion) FROM stdin;
    public          postgres    false    224   �o       �          0    16610    paises 
   TABLE DATA           ;   COPY public.paises (nombre_pais, id_promocion) FROM stdin;
    public          postgres    false    229   �o       v          0    16475    producto 
   TABLE DATA           B   COPY public.producto (id_producto, puntuacion, costo) FROM stdin;
    public          postgres    false    218   bp       �          0    16601 	   promocion 
   TABLE DATA           _   COPY public.promocion (id_promocion, descuento, fecha_inicio, fecha_fin, duracion) FROM stdin;
    public          postgres    false    228   �p       z          0    16544 	   proveedor 
   TABLE DATA           d   COPY public.proveedor (id, nombre, correo, direccion, fecha_afiliacion, tipo_proveedor) FROM stdin;
    public          postgres    false    222   yq       ~          0    16590    usuario 
   TABLE DATA           p   COPY public.usuario (id_usuario, correo, nombre, apellido, num_tdc, fecha_venc, cod_vvt, direccion) FROM stdin;
    public          postgres    false    226   Hr       �           0    0    artista_id_artista_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.artista_id_artista_seq', 10, true);
          public          postgres    false    215            �           0    0    compras_id_compra_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.compras_id_compra_seq', 1, false);
          public          postgres    false    230            �           0    0    producto_id_producto_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.producto_id_producto_seq', 10, true);
          public          postgres    false    217            �           0    0    promocion_id_promocion_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.promocion_id_promocion_seq', 10, true);
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
       public            postgres    false    226            �           2620    16609    promocion calcular_duracion    TRIGGER     �   CREATE TRIGGER calcular_duracion BEFORE INSERT OR UPDATE ON public.promocion FOR EACH ROW EXECUTE FUNCTION public.actualizar_duracion();
 4   DROP TRIGGER calcular_duracion ON public.promocion;
       public          postgres    false    228    232            �           2606    16680 !   aplicacion fk_aplicacion_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT fk_aplicacion_producto FOREIGN KEY (id_aplicacion) REFERENCES public.producto(id_producto);
 K   ALTER TABLE ONLY public.aplicacion DROP CONSTRAINT fk_aplicacion_producto;
       public          postgres    false    218    223    3269            �           2606    16567 "   aplicacion fk_aplicacion_proveedor    FK CONSTRAINT     �   ALTER TABLE ONLY public.aplicacion
    ADD CONSTRAINT fk_aplicacion_proveedor FOREIGN KEY (id_proveedor) REFERENCES public.proveedor(id);
 L   ALTER TABLE ONLY public.aplicacion DROP CONSTRAINT fk_aplicacion_proveedor;
       public          postgres    false    223    3275    222            �           2606    16469     artista fk_artista_casa_disquera    FK CONSTRAINT     �   ALTER TABLE ONLY public.artista
    ADD CONSTRAINT fk_artista_casa_disquera FOREIGN KEY (nombre_casa_disquera) REFERENCES public.casa_disquera(nombre) ON UPDATE CASCADE ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.artista DROP CONSTRAINT fk_artista_casa_disquera;
       public          postgres    false    3265    214    216            �           2606    16519    cancion fk_cancion_artista    FK CONSTRAINT     �   ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT fk_cancion_artista FOREIGN KEY (id_artista) REFERENCES public.artista(id_artista);
 D   ALTER TABLE ONLY public.cancion DROP CONSTRAINT fk_cancion_artista;
       public          postgres    false    219    216    3267            �           2606    16670    cancion fk_cancion_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT fk_cancion_producto FOREIGN KEY (id_cancion) REFERENCES public.producto(id_producto);
 E   ALTER TABLE ONLY public.cancion DROP CONSTRAINT fk_cancion_producto;
       public          postgres    false    218    219    3269            �           2606    16685    compras fk_compras_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_producto FOREIGN KEY (id_producto) REFERENCES public.producto(id_producto);
 E   ALTER TABLE ONLY public.compras DROP CONSTRAINT fk_compras_producto;
       public          postgres    false    218    3269    231            �           2606    16635    compras fk_compras_promo    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_promo FOREIGN KEY (id_promo) REFERENCES public.promocion(id_promocion);
 B   ALTER TABLE ONLY public.compras DROP CONSTRAINT fk_compras_promo;
       public          postgres    false    3283    231    228            �           2606    16640    compras fk_compras_usuario    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras
    ADD CONSTRAINT fk_compras_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);
 D   ALTER TABLE ONLY public.compras DROP CONSTRAINT fk_compras_usuario;
       public          postgres    false    226    3281    231            �           2606    16584 -   dispositivo_com fk_dispositivo_com_aplicacion    FK CONSTRAINT     �   ALTER TABLE ONLY public.dispositivo_com
    ADD CONSTRAINT fk_dispositivo_com_aplicacion FOREIGN KEY (id_aplicacion) REFERENCES public.aplicacion(id_aplicacion);
 W   ALTER TABLE ONLY public.dispositivo_com DROP CONSTRAINT fk_dispositivo_com_aplicacion;
       public          postgres    false    3277    223    224            �           2606    16675 #   dispositivo fk_dispositivo_producto    FK CONSTRAINT     �   ALTER TABLE ONLY public.dispositivo
    ADD CONSTRAINT fk_dispositivo_producto FOREIGN KEY (id_dispositivo) REFERENCES public.producto(id_producto);
 M   ALTER TABLE ONLY public.dispositivo DROP CONSTRAINT fk_dispositivo_producto;
       public          postgres    false    220    3269    218            �           2606    16615    paises fk_key_promocion    FK CONSTRAINT     �   ALTER TABLE ONLY public.paises
    ADD CONSTRAINT fk_key_promocion FOREIGN KEY (id_promocion) REFERENCES public.promocion(id_promocion);
 A   ALTER TABLE ONLY public.paises DROP CONSTRAINT fk_key_promocion;
       public          postgres    false    229    3283    228            {   N  x�MR�N�0<���_P�y��@ABmE����K�*�QlW����_�:v�jr�z4�㈦ 1+`5��*�K������Q����E���T>�tM@�iIȊ�y��_|gOؑT���V�ց(�XEHE>�Qro�t�d��H�Ӡͤ^려2�Q^5!�ο=9��{m��YE�Uv�]� jpiS�$w{t^�L��0��=�h@g:'�r\r��9�4�h���68�(�9|&� l��GY��2Q���n;�2��Y@�-�� �O���X�Dӈ����(?�?��^dI�i�x�͔k�~�$~5Y.oҤ߀��!�S ���dG;��c��"��      t   �   x�]л
�@@�z�+��f�.cⳈ�ڥ	a�m��������n�z^+�)i��&������hC�����0�3��.@Ƭ#�	v� gד˅��)z�=�BJ��J����7�*vGr�t#B��D��:?4������fy��Tˉ?0n��qb      w   �   x�U�=N�@����)r���7e��q\��4Ʋ"cG!.�q����LVHo��G����n_����@2u>8a(کn��j#�\�P���Dʼ�A�M{�(x��O�� B�|\�w[hd"b^l1E���w�3��5X"������ %L����mo�����yRqV�)�y�.�3;hb&e���k��iU�E�5�f�-�p������h�G�1O��k2d�����?3cԿ{{~���'��      r   �   x�E�;�0��99��P���M��HL,��!�4"}܇�p2ҁx����la������������f��Y�TPQ�8�?��9(G�"g���(�@�Ie�Qo�)�Y���p�^�9aIHLZr]!K����_�2���e�;�~�Q[�>�#�'����!0(��q�/�x\IGJ�`ec�      �      x������ � �      x   �   x�Mλ
�P��z�)���s�I��F���4� ��;�.X_�)9�4)���a+��5�f�P�fZ�n0���Y��n%�{�X-��`����t�=�Zr:��?�Zv���O�ֹ��ޟX��]��=�\�t�s�k�D      |      x������ � �      �   p   x�s-.H<�$�Ӑ��Qì���|N#.Ǣ�Լ�̼DNc.����ܤ�DN��ԢC�9M��32sR9͸\�KS�8͹�KKRss9-��K�9-���s2ˀ��b���� a� �      v   �   x�%��C1Ϣ������%���;�^�5+*���hOb�c%�C&��Iѝ�zU%�`t��-���\E�6���XHG
޲�crT^��;�w4�6/ڬ��W`{8^ .���-�h�;A�t*=�~ � AS!�      �   s   x�E��1D�s��[f�K�� 4����<!StL����I�\IWr �4�Ү�� e��sɡe���]в��J�aewם��ʞ�'녗�]o��y~9�?~"���2�      z   �   x�u�A�0��u{
/ �--�C��pCJ$`ɘx ���l��4�����[�`7�/�f'��p^��q+��ذ��v��a"+�
!
a���_�),�L$���%IK*�J��-ՉT�T�RMK:�4J��4-6n;��錎����T�ob����&׷��b�R}����wT��zQE`<���0���s�W���      ~   �  x�m�Kn�0����@�-�(q��������&h2�$/��9����DG�I2lŖ��`@�4�&0�3:e�wr�J��v73������#$���Qr
�"��DB?H�Z�Z��9�gi�H�0����	�����RSV0�`��pq�F�;%�ON�O�</J�9����F�E7-'C�6A	U�x��,/`�񈼕fr�yU7,j�-:mG� �Y��@p��P�
�N ����[;�2tOD`��ٯ�����ЅP���-�
>�/h�{��~�yg5�gX�2�}#����gMz<8_���^/�:�O�yv���g"cUp�Ƚ��^�����l�Y�)�V[��Бo�ur��Y�: ���n9�τ�]�/Y���u#�N�j��W4@*�Ҏ�f�Q�&�͛ҍ�nԞگH�m�&��x�����q6��-q�)�[k&\~"/E���Ј7��{�7�v��G'�����������+Q��猱W��      