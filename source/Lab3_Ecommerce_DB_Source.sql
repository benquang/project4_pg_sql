--
-- PostgreSQL database dump
--

\restrict 5ffSBKVPor2DBUZKb3exTGcVxZxg6WYWHjG05NTs96sSwqMbKWPo0TqPofxGH9k

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-21 21:45:45

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 240 (class 1255 OID 18610)
-- Name: daily_revenue_report(date, date, integer[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.daily_revenue_report(start_date date, end_date date, product_list integer[]) RETURNS TABLE(date date, total_orders bigint, total_quantity bigint, total_revenue numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.order_date::DATE AS date,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM orders_ranges o
    JOIN order_item_ranges oi ON o.order_id = oi.order_id
    WHERE o.order_date BETWEEN start_date AND end_date
      AND oi.product_id = ANY(product_list)   -- filter with product_id list
    GROUP BY o.order_date::DATE
    ORDER BY date;
END;
$$;


ALTER FUNCTION public.daily_revenue_report(start_date date, end_date date, product_list integer[]) OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 18609)
-- Name: monthly_revenue_report(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.monthly_revenue_report(start_date date, end_date date) RETURNS TABLE(month date, total_orders bigint, total_quantity bigint, total_revenue numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        DATE_TRUNC('month', o.order_date)::DATE AS month,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM orders_ranges o
    JOIN order_item_ranges oi ON o.order_id = oi.order_id
    WHERE o.order_date BETWEEN start_date AND end_date
    GROUP BY DATE_TRUNC('month', o.order_date)
    ORDER BY month;
END;
$$;


ALTER FUNCTION public.monthly_revenue_report(start_date date, end_date date) OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 18617)
-- Name: orders_status_summary(date, date, integer[], integer[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.orders_status_summary(start_date date, end_date date, seller_list integer[] DEFAULT NULL::integer[], category_list integer[] DEFAULT NULL::integer[]) RETURNS TABLE(status character varying, total_orders bigint, total_revenue numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.status,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_revenue
    FROM orders_ranges o
    JOIN order_item_ranges oi ON o.order_id = oi.order_id
    JOIN product p ON oi.product_id = p.product_id
    WHERE o.order_date BETWEEN start_date AND end_date
      AND (seller_list IS NULL OR o.seller_id = ANY(seller_list))
      AND (category_list IS NULL OR p.category_id = ANY(category_list))
    GROUP BY o.status
    ORDER BY o.status;
END;
$$;


ALTER FUNCTION public.orders_status_summary(start_date date, end_date date, seller_list integer[], category_list integer[]) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 18615)
-- Name: seller_performance_report(date, date, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.seller_performance_report(start_date date, end_date date, category_filter integer DEFAULT NULL::integer, brand_filter integer DEFAULT NULL::integer) RETURNS TABLE(seller_id integer, seller_name text, total_orders bigint, total_quantity bigint, total_revenue numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.seller_id,
        s.seller_name::TEXT,   -- into TEXT
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM orders_ranges o
    JOIN seller s ON o.seller_id = s.seller_id
    JOIN order_item_ranges oi ON o.order_id = oi.order_id
    JOIN product p ON oi.product_id = p.product_id
    WHERE o.order_date BETWEEN start_date AND end_date
      AND (category_filter IS NULL OR p.category_id = category_filter)
      AND (brand_filter IS NULL OR p.brand_id = brand_filter)
    GROUP BY s.seller_id, s.seller_name
    ORDER BY total_revenue DESC;
END;
$$;


ALTER FUNCTION public.seller_performance_report(start_date date, end_date date, category_filter integer, brand_filter integer) OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 18616)
-- Name: top_products_per_brand(date, date, integer[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.top_products_per_brand(start_date date, end_date date, seller_list integer[] DEFAULT NULL::integer[]) RETURNS TABLE(brand_id integer, brand_name character varying, product_id integer, product_name character varying, total_quantity bigint, total_revenue numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.brand_id,
        b.brand_name,
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM orders_ranges o
    JOIN order_item_ranges oi ON o.order_id = oi.order_id
    JOIN product p ON oi.product_id = p.product_id
    JOIN brand b ON p.brand_id = b.brand_id
    WHERE o.order_date BETWEEN start_date AND end_date
      AND (seller_list IS NULL OR o.seller_id = ANY(seller_list))
    GROUP BY b.brand_id, b.brand_name, p.product_id, p.product_name
    ORDER BY b.brand_id, total_quantity DESC;
END;
$$;


ALTER FUNCTION public.top_products_per_brand(start_date date, end_date date, seller_list integer[]) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 219 (class 1259 OID 17636)
-- Name: brand; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.brand (
    brand_id integer NOT NULL,
    brand_name character varying(100) NOT NULL,
    country character varying(50) NOT NULL,
    create_at timestamp without time zone NOT NULL
);


ALTER TABLE public.brand OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 17665)
-- Name: category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category (
    category_id integer NOT NULL,
    category_name character varying(100) NOT NULL,
    parent_category_id integer,
    level smallint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.category OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 18463)
-- Name: order_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_item (
    order_item_id integer NOT NULL,
    order_id integer,
    product_id integer,
    order_date timestamp without time zone NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    subtotal numeric(12,2) GENERATED ALWAYS AS (((quantity)::numeric * unit_price)) STORED,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.order_item OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 18537)
-- Name: order_item_ranges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_item_ranges (
    order_item_id integer NOT NULL,
    order_id integer,
    product_id integer,
    order_date timestamp without time zone NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    subtotal numeric(12,2) GENERATED ALWAYS AS (((quantity)::numeric * unit_price)) STORED,
    created_at timestamp without time zone NOT NULL
)
PARTITION BY RANGE (order_date);


ALTER TABLE public.order_item_ranges OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 18536)
-- Name: order_item_ranges_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_item_ranges_order_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_item_ranges_order_item_id_seq OWNER TO postgres;

--
-- TOC entry 5132 (class 0 OID 0)
-- Dependencies: 234
-- Name: order_item_ranges_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_item_ranges_order_item_id_seq OWNED BY public.order_item_ranges.order_item_id;


--
-- TOC entry 236 (class 1259 OID 18557)
-- Name: order_item_2025_08; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_item_2025_08 (
    order_item_id integer DEFAULT nextval('public.order_item_ranges_order_item_id_seq'::regclass) CONSTRAINT order_item_ranges_order_item_id_not_null NOT NULL,
    order_id integer,
    product_id integer,
    order_date timestamp without time zone CONSTRAINT order_item_ranges_order_date_not_null NOT NULL,
    quantity integer CONSTRAINT order_item_ranges_quantity_not_null NOT NULL,
    unit_price numeric(12,2) CONSTRAINT order_item_ranges_unit_price_not_null NOT NULL,
    subtotal numeric(12,2) GENERATED ALWAYS AS (((quantity)::numeric * unit_price)) STORED,
    created_at timestamp without time zone CONSTRAINT order_item_ranges_created_at_not_null NOT NULL
);


ALTER TABLE public.order_item_2025_08 OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 18573)
-- Name: order_item_2025_09; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_item_2025_09 (
    order_item_id integer DEFAULT nextval('public.order_item_ranges_order_item_id_seq'::regclass) CONSTRAINT order_item_ranges_order_item_id_not_null NOT NULL,
    order_id integer,
    product_id integer,
    order_date timestamp without time zone CONSTRAINT order_item_ranges_order_date_not_null NOT NULL,
    quantity integer CONSTRAINT order_item_ranges_quantity_not_null NOT NULL,
    unit_price numeric(12,2) CONSTRAINT order_item_ranges_unit_price_not_null NOT NULL,
    subtotal numeric(12,2) GENERATED ALWAYS AS (((quantity)::numeric * unit_price)) STORED,
    created_at timestamp without time zone CONSTRAINT order_item_ranges_created_at_not_null NOT NULL
);


ALTER TABLE public.order_item_2025_09 OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 18589)
-- Name: order_item_2025_10; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_item_2025_10 (
    order_item_id integer DEFAULT nextval('public.order_item_ranges_order_item_id_seq'::regclass) CONSTRAINT order_item_ranges_order_item_id_not_null NOT NULL,
    order_id integer,
    product_id integer,
    order_date timestamp without time zone CONSTRAINT order_item_ranges_order_date_not_null NOT NULL,
    quantity integer CONSTRAINT order_item_ranges_quantity_not_null NOT NULL,
    unit_price numeric(12,2) CONSTRAINT order_item_ranges_unit_price_not_null NOT NULL,
    subtotal numeric(12,2) GENERATED ALWAYS AS (((quantity)::numeric * unit_price)) STORED,
    created_at timestamp without time zone CONSTRAINT order_item_ranges_created_at_not_null NOT NULL
);


ALTER TABLE public.order_item_2025_10 OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 18462)
-- Name: order_item_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_item_order_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_item_order_item_id_seq OWNER TO postgres;

--
-- TOC entry 5133 (class 0 OID 0)
-- Dependencies: 227
-- Name: order_item_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_item_order_item_id_seq OWNED BY public.order_item.order_item_id;


--
-- TOC entry 226 (class 1259 OID 18446)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    order_date timestamp without time zone NOT NULL,
    seller_id integer,
    status character varying(20) NOT NULL,
    total_amount numeric(12,2) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 18486)
-- Name: orders_ranges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders_ranges (
    order_id integer NOT NULL,
    order_date timestamp without time zone NOT NULL,
    seller_id integer,
    status character varying(20) NOT NULL,
    total_amount numeric(12,2) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
)
PARTITION BY RANGE (order_date);


ALTER TABLE public.orders_ranges OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 18485)
-- Name: orders_ranges_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_ranges_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_ranges_order_id_seq OWNER TO postgres;

--
-- TOC entry 5134 (class 0 OID 0)
-- Dependencies: 229
-- Name: orders_ranges_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_ranges_order_id_seq OWNED BY public.orders_ranges.order_id;


--
-- TOC entry 231 (class 1259 OID 18500)
-- Name: orders_2025_08; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders_2025_08 (
    order_id integer DEFAULT nextval('public.orders_ranges_order_id_seq'::regclass) CONSTRAINT orders_ranges_order_id_not_null NOT NULL,
    order_date timestamp without time zone CONSTRAINT orders_ranges_order_date_not_null NOT NULL,
    seller_id integer,
    status character varying(20) CONSTRAINT orders_ranges_status_not_null NOT NULL,
    total_amount numeric(12,2) CONSTRAINT orders_ranges_total_amount_not_null NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.orders_2025_08 OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 18512)
-- Name: orders_2025_09; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders_2025_09 (
    order_id integer DEFAULT nextval('public.orders_ranges_order_id_seq'::regclass) CONSTRAINT orders_ranges_order_id_not_null NOT NULL,
    order_date timestamp without time zone CONSTRAINT orders_ranges_order_date_not_null NOT NULL,
    seller_id integer,
    status character varying(20) CONSTRAINT orders_ranges_status_not_null NOT NULL,
    total_amount numeric(12,2) CONSTRAINT orders_ranges_total_amount_not_null NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.orders_2025_09 OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 18524)
-- Name: orders_2025_10; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders_2025_10 (
    order_id integer DEFAULT nextval('public.orders_ranges_order_id_seq'::regclass) CONSTRAINT orders_ranges_order_id_not_null NOT NULL,
    order_date timestamp without time zone CONSTRAINT orders_ranges_order_date_not_null NOT NULL,
    seller_id integer,
    status character varying(20) CONSTRAINT orders_ranges_status_not_null NOT NULL,
    total_amount numeric(12,2) CONSTRAINT orders_ranges_total_amount_not_null NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.orders_2025_10 OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 18445)
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_order_id_seq OWNER TO postgres;

--
-- TOC entry 5135 (class 0 OID 0)
-- Dependencies: 225
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- TOC entry 222 (class 1259 OID 17674)
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    product_id integer NOT NULL,
    product_name character varying(200) NOT NULL,
    category_id integer,
    brand_id integer,
    seller_id integer,
    price numeric(12,2) NOT NULL,
    discount_price numeric(12,2) NOT NULL,
    stock_qty integer NOT NULL,
    rating double precision NOT NULL,
    created_at date NOT NULL,
    is_active boolean NOT NULL
);


ALTER TABLE public.product OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17736)
-- Name: promotion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion (
    promotion_id integer NOT NULL,
    promotion_name character varying(100) NOT NULL,
    promotion_type character varying(50) NOT NULL,
    discount_type character varying(20) NOT NULL,
    discount_value numeric(10,2) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL
);


ALTER TABLE public.promotion OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 17748)
-- Name: promotion_product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion_product (
    promotion_product_id integer NOT NULL,
    promotion_id integer,
    product_id integer,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.promotion_product OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 17654)
-- Name: seller; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.seller (
    seller_id integer NOT NULL,
    seller_name character varying(150) NOT NULL,
    join_date date NOT NULL,
    seller_type character varying(50) NOT NULL,
    rating numeric(2,1) NOT NULL,
    country character varying(50) NOT NULL
);


ALTER TABLE public.seller OWNER TO postgres;

--
-- TOC entry 4927 (class 0 OID 0)
-- Name: order_item_2025_08; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item_ranges ATTACH PARTITION public.order_item_2025_08 FOR VALUES FROM ('2025-08-01 00:00:00') TO ('2025-09-01 00:00:00');


--
-- TOC entry 4928 (class 0 OID 0)
-- Name: order_item_2025_09; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item_ranges ATTACH PARTITION public.order_item_2025_09 FOR VALUES FROM ('2025-09-01 00:00:00') TO ('2025-10-01 00:00:00');


--
-- TOC entry 4929 (class 0 OID 0)
-- Name: order_item_2025_10; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item_ranges ATTACH PARTITION public.order_item_2025_10 FOR VALUES FROM ('2025-10-01 00:00:00') TO ('2025-11-01 00:00:00');


--
-- TOC entry 4924 (class 0 OID 0)
-- Name: orders_2025_08; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders_ranges ATTACH PARTITION public.orders_2025_08 FOR VALUES FROM ('2025-08-01 00:00:00') TO ('2025-09-01 00:00:00');


--
-- TOC entry 4925 (class 0 OID 0)
-- Name: orders_2025_09; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders_ranges ATTACH PARTITION public.orders_2025_09 FOR VALUES FROM ('2025-09-01 00:00:00') TO ('2025-10-01 00:00:00');


--
-- TOC entry 4926 (class 0 OID 0)
-- Name: orders_2025_10; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders_ranges ATTACH PARTITION public.orders_2025_10 FOR VALUES FROM ('2025-10-01 00:00:00') TO ('2025-11-01 00:00:00');


--
-- TOC entry 4932 (class 2604 OID 18466)
-- Name: order_item order_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item ALTER COLUMN order_item_id SET DEFAULT nextval('public.order_item_order_item_id_seq'::regclass);


--
-- TOC entry 4942 (class 2604 OID 18540)
-- Name: order_item_ranges order_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item_ranges ALTER COLUMN order_item_id SET DEFAULT nextval('public.order_item_ranges_order_item_id_seq'::regclass);


--
-- TOC entry 4930 (class 2604 OID 18449)
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- TOC entry 4934 (class 2604 OID 18489)
-- Name: orders_ranges order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders_ranges ALTER COLUMN order_id SET DEFAULT nextval('public.orders_ranges_order_id_seq'::regclass);


--
-- TOC entry 4951 (class 2606 OID 17644)
-- Name: brand brand_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brand
    ADD CONSTRAINT brand_pkey PRIMARY KEY (brand_id);


--
-- TOC entry 4955 (class 2606 OID 17673)
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (category_id);


--
-- TOC entry 4965 (class 2606 OID 18474)
-- Name: order_item order_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_pkey PRIMARY KEY (order_item_id);


--
-- TOC entry 4963 (class 2606 OID 18456)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- TOC entry 4957 (class 2606 OID 17686)
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (product_id);


--
-- TOC entry 4959 (class 2606 OID 17747)
-- Name: promotion promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (promotion_id);


--
-- TOC entry 4961 (class 2606 OID 17754)
-- Name: promotion_product promotion_product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_product
    ADD CONSTRAINT promotion_product_pkey PRIMARY KEY (promotion_product_id);


--
-- TOC entry 4953 (class 2606 OID 17664)
-- Name: seller seller_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seller
    ADD CONSTRAINT seller_pkey PRIMARY KEY (seller_id);


--
-- TOC entry 4966 (class 1259 OID 18605)
-- Name: idx_order_item_2025_08_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_item_2025_08_product_id ON public.order_item_2025_08 USING btree (product_id);


--
-- TOC entry 4967 (class 1259 OID 18606)
-- Name: idx_order_item_2025_09_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_item_2025_09_product_id ON public.order_item_2025_09 USING btree (product_id);


--
-- TOC entry 4968 (class 1259 OID 18607)
-- Name: idx_order_item_2025_10_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_item_2025_10_product_id ON public.order_item_2025_10 USING btree (product_id);


--
-- TOC entry 4975 (class 2606 OID 18475)
-- Name: order_item order_item_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- TOC entry 4976 (class 2606 OID 18480)
-- Name: order_item order_item_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(product_id);


--
-- TOC entry 4978 (class 2606 OID 18547)
-- Name: order_item_ranges order_item_ranges_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.order_item_ranges
    ADD CONSTRAINT order_item_ranges_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- TOC entry 4979 (class 2606 OID 18552)
-- Name: order_item_ranges order_item_ranges_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.order_item_ranges
    ADD CONSTRAINT order_item_ranges_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(product_id);


--
-- TOC entry 4977 (class 2606 OID 18495)
-- Name: orders_ranges orders_ranges_seller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.orders_ranges
    ADD CONSTRAINT orders_ranges_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES public.seller(seller_id);


--
-- TOC entry 4974 (class 2606 OID 18457)
-- Name: orders orders_seller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES public.seller(seller_id);


--
-- TOC entry 4969 (class 2606 OID 17692)
-- Name: product product_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_brand_id_fkey FOREIGN KEY (brand_id) REFERENCES public.brand(brand_id);


--
-- TOC entry 4970 (class 2606 OID 17687)
-- Name: product product_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(category_id);


--
-- TOC entry 4971 (class 2606 OID 17697)
-- Name: product product_seller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES public.seller(seller_id);


--
-- TOC entry 4972 (class 2606 OID 17760)
-- Name: promotion_product promotion_product_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_product
    ADD CONSTRAINT promotion_product_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(product_id);


--
-- TOC entry 4973 (class 2606 OID 17755)
-- Name: promotion_product promotion_product_promotion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_product
    ADD CONSTRAINT promotion_product_promotion_id_fkey FOREIGN KEY (promotion_id) REFERENCES public.promotion(promotion_id);


-- Completed on 2026-04-21 21:45:45

--
-- PostgreSQL database dump complete
--

\unrestrict 5ffSBKVPor2DBUZKb3exTGcVxZxg6WYWHjG05NTs96sSwqMbKWPo0TqPofxGH9k

