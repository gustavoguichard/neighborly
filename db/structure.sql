--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    name text NOT NULL,
    user_id integer NOT NULL,
    category_id integer NOT NULL,
    goal numeric NOT NULL,
    summary text NOT NULL,
    headline text NOT NULL,
    video_url text,
    short_url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    summary_html text,
    recommended boolean DEFAULT false,
    home_page_comment text,
    permalink text NOT NULL,
    video_thumbnail text,
    state character varying(255),
    online_days integer DEFAULT 0,
    online_date timestamp with time zone,
    how_know text,
    more_urls text,
    first_contributions text,
    uploaded_image character varying(255),
    video_embed_url character varying(255),
    budget text,
    budget_html text,
    terms text,
    terms_html text,
    site character varying(255),
    hash_tag character varying(255),
    address_city character varying(255),
    address_state character varying(255),
    address_zip_code character varying(255),
    address_neighborhood character varying(255),
    featured boolean DEFAULT false,
    home_page boolean,
    summary_textile text,
    budget_textile text,
    terms_textile text,
    latitude double precision,
    longitude double precision,
    hero_image character varying(255),
    sent_to_analysis_at timestamp without time zone,
    organization_type character varying(255),
    street_address character varying(255),
    credit_type integer NOT NULL,
    minimum_investment numeric NOT NULL,
    rating integer,
    rating_agency character varying(255),
    statement_file_url character varying(255) NOT NULL,
    sale_date timestamp without time zone,
    CONSTRAINT projects_about_not_blank CHECK ((length(btrim(summary)) > 0)),
    CONSTRAINT projects_headline_length_within CHECK (((length(headline) >= 1) AND (length(headline) <= 140))),
    CONSTRAINT projects_headline_not_blank CHECK ((length(btrim(headline)) > 0))
);


--
-- Name: expires_at(projects); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION expires_at(projects) RETURNS timestamp with time zone
    LANGUAGE sql
    AS $_$
               SELECT ((($1.online_date AT TIME ZONE 'America/Chicago' + ($1.online_days || ' days')::interval)::date::text || ' 23:59:59')::timestamp AT TIME ZONE 'America/Chicago')
              $_$;


--
-- Name: access_codes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE access_codes (
    id integer NOT NULL,
    code character varying(255),
    max_users integer DEFAULT 1,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: access_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE access_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: access_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE access_codes_id_seq OWNED BY access_codes.id;


--
-- Name: activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE activities (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    happened_at timestamp without time zone NOT NULL,
    summary character varying(255),
    project_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE activities_id_seq OWNED BY activities.id;


--
-- Name: api_access_tokens; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE api_access_tokens (
    id integer NOT NULL,
    code character varying(255) NOT NULL,
    expired boolean DEFAULT false NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: api_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE api_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE api_access_tokens_id_seq OWNED BY api_access_tokens.id;


--
-- Name: authorizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE authorizations (
    id integer NOT NULL,
    oauth_provider_id integer NOT NULL,
    user_id integer NOT NULL,
    uid text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    access_token character varying(255),
    access_token_secret character varying(255),
    access_token_expires_at timestamp without time zone
);


--
-- Name: authorizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authorizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authorizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authorizations_id_seq OWNED BY authorizations.id;


--
-- Name: balanced_contributors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE balanced_contributors (
    id integer NOT NULL,
    user_id integer,
    href character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    bank_account_href character varying(255)
);


--
-- Name: balanced_contributors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE balanced_contributors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: balanced_contributors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE balanced_contributors_id_seq OWNED BY balanced_contributors.id;


--
-- Name: brokerage_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE brokerage_accounts (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    address character varying(255) NOT NULL,
    tax_id character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    phone character varying(255) NOT NULL,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: brokerage_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brokerage_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brokerage_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brokerage_accounts_id_seq OWNED BY brokerage_accounts.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying(255) NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contacts (
    id integer NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    phone character varying(255),
    message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    subject character varying(255)
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_id_seq OWNED BY contacts.id;


--
-- Name: contributions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contributions (
    id integer NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    reward_id integer,
    value numeric NOT NULL,
    confirmed_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    anonymous boolean DEFAULT false,
    key text,
    payment_method text,
    payment_token text,
    payment_id character varying(255),
    payer_name text,
    payer_email text,
    payer_document text,
    address_street text,
    address_number text,
    address_complement text,
    address_neighborhood text,
    address_zip_code text,
    address_city text,
    address_state text,
    address_phone_number text,
    payment_choice text,
    payment_service_fee numeric DEFAULT 0 NOT NULL,
    state character varying(255),
    short_note text,
    bonds integer DEFAULT 1 NOT NULL,
    CONSTRAINT backers_value_positive CHECK ((value >= (0)::numeric))
);


--
-- Name: contributions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contributions_id_seq OWNED BY contributions.id;


--
-- Name: funding_raised_per_project_reports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE funding_raised_per_project_reports (
    project_id integer,
    project_name text,
    total_raised numeric,
    total_backs bigint,
    total_backers bigint
);


--
-- Name: images; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE images (
    id integer NOT NULL,
    file character varying(255) NOT NULL,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE images_id_seq OWNED BY images.id;


--
-- Name: investment_prospects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE investment_prospects (
    id integer NOT NULL,
    user_id integer,
    value double precision DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: investment_prospects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE investment_prospects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: investment_prospects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE investment_prospects_id_seq OWNED BY investment_prospects.id;


--
-- Name: neighborly_balanced_orders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE neighborly_balanced_orders (
    id integer NOT NULL,
    project_id integer NOT NULL,
    href character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: neighborly_balanced_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE neighborly_balanced_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: neighborly_balanced_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE neighborly_balanced_orders_id_seq OWNED BY neighborly_balanced_orders.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    project_id integer,
    dismissed boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    contribution_id integer,
    origin_email text NOT NULL,
    origin_name text NOT NULL,
    template_name text NOT NULL,
    locale text NOT NULL,
    contact_id integer,
    bcc character varying(255)
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: oauth_providers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_providers (
    id integer NOT NULL,
    name text NOT NULL,
    key text NOT NULL,
    secret text NOT NULL,
    scope text,
    "order" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    strategy text,
    path text,
    CONSTRAINT oauth_providers_key_not_blank CHECK ((length(btrim(key)) > 0)),
    CONSTRAINT oauth_providers_name_not_blank CHECK ((length(btrim(name)) > 0)),
    CONSTRAINT oauth_providers_secret_not_blank CHECK ((length(btrim(secret)) > 0))
);


--
-- Name: oauth_providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_providers_id_seq OWNED BY oauth_providers.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organizations (
    id integer NOT NULL,
    name character varying(255),
    image character varying(255),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organizations_id_seq OWNED BY organizations.id;


--
-- Name: payment_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payment_notifications (
    id integer NOT NULL,
    contribution_id integer NOT NULL,
    extra_data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: payment_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payment_notifications_id_seq OWNED BY payment_notifications.id;


--
-- Name: press_assets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE press_assets (
    id integer NOT NULL,
    title character varying(255),
    image text,
    url character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: press_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE press_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: press_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE press_assets_id_seq OWNED BY press_assets.id;


--
-- Name: project_documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_documents (
    id integer NOT NULL,
    document text,
    project_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying(255)
);


--
-- Name: project_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_documents_id_seq OWNED BY project_documents.id;


--
-- Name: project_faqs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_faqs (
    id integer NOT NULL,
    answer text,
    title text,
    project_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: project_faqs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_faqs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_faqs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_faqs_id_seq OWNED BY project_faqs.id;


--
-- Name: project_totals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_totals (
    id integer NOT NULL,
    project_id integer,
    net_amount numeric DEFAULT 0,
    platform_fee numeric DEFAULT 0,
    pledged numeric DEFAULT 0,
    progress integer DEFAULT 0,
    total_contributions integer DEFAULT 0,
    total_payment_service_fee numeric DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: project_totals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_totals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_totals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_totals_id_seq OWNED BY project_totals.id;


--
-- Name: projects_for_home; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW projects_for_home AS
 WITH featured_projects AS (
         SELECT 'featured'::text AS origin,
            featureds.id,
            featureds.name,
            featureds.user_id,
            featureds.category_id,
            featureds.goal,
            featureds.summary,
            featureds.headline,
            featureds.video_url,
            featureds.short_url,
            featureds.created_at,
            featureds.updated_at,
            featureds.summary_html,
            featureds.recommended,
            featureds.home_page_comment,
            featureds.permalink,
            featureds.video_thumbnail,
            featureds.state,
            featureds.online_days,
            featureds.online_date,
            featureds.how_know,
            featureds.more_urls,
            featureds.first_contributions,
            featureds.uploaded_image,
            featureds.video_embed_url,
            featureds.budget,
            featureds.budget_html,
            featureds.terms,
            featureds.terms_html,
            featureds.site,
            featureds.hash_tag,
            featureds.address_city,
            featureds.address_state,
            featureds.address_zip_code,
            featureds.address_neighborhood,
            featureds.featured,
            featureds.home_page,
            featureds.summary_textile,
            featureds.budget_textile,
            featureds.terms_textile,
            featureds.latitude,
            featureds.longitude,
            featureds.hero_image,
            featureds.sent_to_analysis_at,
            featureds.organization_type,
            featureds.street_address,
            featureds.credit_type,
            featureds.minimum_investment,
            featureds.rating,
            featureds.rating_agency,
            featureds.statement_file_url,
            featureds.sale_date
           FROM projects featureds
          WHERE (featureds.featured AND ((featureds.state)::text = 'online'::text))
         LIMIT 1
        ), recommended_projects AS (
         SELECT 'recommended'::text AS origin,
            recommends.id,
            recommends.name,
            recommends.user_id,
            recommends.category_id,
            recommends.goal,
            recommends.summary,
            recommends.headline,
            recommends.video_url,
            recommends.short_url,
            recommends.created_at,
            recommends.updated_at,
            recommends.summary_html,
            recommends.recommended,
            recommends.home_page_comment,
            recommends.permalink,
            recommends.video_thumbnail,
            recommends.state,
            recommends.online_days,
            recommends.online_date,
            recommends.how_know,
            recommends.more_urls,
            recommends.first_contributions,
            recommends.uploaded_image,
            recommends.video_embed_url,
            recommends.budget,
            recommends.budget_html,
            recommends.terms,
            recommends.terms_html,
            recommends.site,
            recommends.hash_tag,
            recommends.address_city,
            recommends.address_state,
            recommends.address_zip_code,
            recommends.address_neighborhood,
            recommends.featured,
            recommends.home_page,
            recommends.summary_textile,
            recommends.budget_textile,
            recommends.terms_textile,
            recommends.latitude,
            recommends.longitude,
            recommends.hero_image,
            recommends.sent_to_analysis_at,
            recommends.organization_type,
            recommends.street_address,
            recommends.credit_type,
            recommends.minimum_investment,
            recommends.rating,
            recommends.rating_agency,
            recommends.statement_file_url,
            recommends.sale_date
           FROM projects recommends
          WHERE (((recommends.recommended AND ((recommends.state)::text = 'online'::text)) AND recommends.home_page) AND (NOT (recommends.id IN ( SELECT featureds.id
                   FROM featured_projects featureds))))
          ORDER BY random()
         LIMIT 5
        ), expiring_projects AS (
         SELECT 'expiring'::text AS origin,
            expiring.id,
            expiring.name,
            expiring.user_id,
            expiring.category_id,
            expiring.goal,
            expiring.summary,
            expiring.headline,
            expiring.video_url,
            expiring.short_url,
            expiring.created_at,
            expiring.updated_at,
            expiring.summary_html,
            expiring.recommended,
            expiring.home_page_comment,
            expiring.permalink,
            expiring.video_thumbnail,
            expiring.state,
            expiring.online_days,
            expiring.online_date,
            expiring.how_know,
            expiring.more_urls,
            expiring.first_contributions,
            expiring.uploaded_image,
            expiring.video_embed_url,
            expiring.budget,
            expiring.budget_html,
            expiring.terms,
            expiring.terms_html,
            expiring.site,
            expiring.hash_tag,
            expiring.address_city,
            expiring.address_state,
            expiring.address_zip_code,
            expiring.address_neighborhood,
            expiring.featured,
            expiring.home_page,
            expiring.summary_textile,
            expiring.budget_textile,
            expiring.terms_textile,
            expiring.latitude,
            expiring.longitude,
            expiring.hero_image,
            expiring.sent_to_analysis_at,
            expiring.organization_type,
            expiring.street_address,
            expiring.credit_type,
            expiring.minimum_investment,
            expiring.rating,
            expiring.rating_agency,
            expiring.statement_file_url,
            expiring.sale_date
           FROM projects expiring
          WHERE (((((expiring.state)::text = 'online'::text) AND (expires_at(expiring.*) <= (now() + '14 days'::interval))) AND expiring.home_page) AND (NOT (expiring.id IN ( SELECT recommends.id
                   FROM recommended_projects recommends
                UNION
                 SELECT featureds.id
                   FROM featured_projects featureds))))
          ORDER BY random()
         LIMIT 4
        ), soon_projects AS (
         SELECT 'soon'::text AS origin,
            soon.id,
            soon.name,
            soon.user_id,
            soon.category_id,
            soon.goal,
            soon.summary,
            soon.headline,
            soon.video_url,
            soon.short_url,
            soon.created_at,
            soon.updated_at,
            soon.summary_html,
            soon.recommended,
            soon.home_page_comment,
            soon.permalink,
            soon.video_thumbnail,
            soon.state,
            soon.online_days,
            soon.online_date,
            soon.how_know,
            soon.more_urls,
            soon.first_contributions,
            soon.uploaded_image,
            soon.video_embed_url,
            soon.budget,
            soon.budget_html,
            soon.terms,
            soon.terms_html,
            soon.site,
            soon.hash_tag,
            soon.address_city,
            soon.address_state,
            soon.address_zip_code,
            soon.address_neighborhood,
            soon.featured,
            soon.home_page,
            soon.summary_textile,
            soon.budget_textile,
            soon.terms_textile,
            soon.latitude,
            soon.longitude,
            soon.hero_image,
            soon.sent_to_analysis_at,
            soon.organization_type,
            soon.street_address,
            soon.credit_type,
            soon.minimum_investment,
            soon.rating,
            soon.rating_agency,
            soon.statement_file_url,
            soon.sale_date
           FROM projects soon
          WHERE ((((soon.state)::text = 'soon'::text) AND soon.home_page) AND (soon.uploaded_image IS NOT NULL))
          ORDER BY random()
         LIMIT 4
        ), successful_projects AS (
         SELECT 'successful'::text AS origin,
            successful.id,
            successful.name,
            successful.user_id,
            successful.category_id,
            successful.goal,
            successful.summary,
            successful.headline,
            successful.video_url,
            successful.short_url,
            successful.created_at,
            successful.updated_at,
            successful.summary_html,
            successful.recommended,
            successful.home_page_comment,
            successful.permalink,
            successful.video_thumbnail,
            successful.state,
            successful.online_days,
            successful.online_date,
            successful.how_know,
            successful.more_urls,
            successful.first_contributions,
            successful.uploaded_image,
            successful.video_embed_url,
            successful.budget,
            successful.budget_html,
            successful.terms,
            successful.terms_html,
            successful.site,
            successful.hash_tag,
            successful.address_city,
            successful.address_state,
            successful.address_zip_code,
            successful.address_neighborhood,
            successful.featured,
            successful.home_page,
            successful.summary_textile,
            successful.budget_textile,
            successful.terms_textile,
            successful.latitude,
            successful.longitude,
            successful.hero_image,
            successful.sent_to_analysis_at,
            successful.organization_type,
            successful.street_address,
            successful.credit_type,
            successful.minimum_investment,
            successful.rating,
            successful.rating_agency,
            successful.statement_file_url,
            successful.sale_date
           FROM projects successful
          WHERE (((successful.state)::text = 'successful'::text) AND successful.home_page)
          ORDER BY random()
         LIMIT 4
        )
 SELECT featured_projects.origin,
    featured_projects.id,
    featured_projects.name,
    featured_projects.user_id,
    featured_projects.category_id,
    featured_projects.goal,
    featured_projects.summary,
    featured_projects.headline,
    featured_projects.video_url,
    featured_projects.short_url,
    featured_projects.created_at,
    featured_projects.updated_at,
    featured_projects.summary_html,
    featured_projects.recommended,
    featured_projects.home_page_comment,
    featured_projects.permalink,
    featured_projects.video_thumbnail,
    featured_projects.state,
    featured_projects.online_days,
    featured_projects.online_date,
    featured_projects.how_know,
    featured_projects.more_urls,
    featured_projects.first_contributions,
    featured_projects.uploaded_image,
    featured_projects.video_embed_url,
    featured_projects.budget,
    featured_projects.budget_html,
    featured_projects.terms,
    featured_projects.terms_html,
    featured_projects.site,
    featured_projects.hash_tag,
    featured_projects.address_city,
    featured_projects.address_state,
    featured_projects.address_zip_code,
    featured_projects.address_neighborhood,
    featured_projects.featured,
    featured_projects.home_page,
    featured_projects.summary_textile,
    featured_projects.budget_textile,
    featured_projects.terms_textile,
    featured_projects.latitude,
    featured_projects.longitude,
    featured_projects.hero_image,
    featured_projects.sent_to_analysis_at,
    featured_projects.organization_type,
    featured_projects.street_address,
    featured_projects.credit_type,
    featured_projects.minimum_investment,
    featured_projects.rating,
    featured_projects.rating_agency,
    featured_projects.statement_file_url,
    featured_projects.sale_date
   FROM featured_projects
UNION
 SELECT recommended_projects.origin,
    recommended_projects.id,
    recommended_projects.name,
    recommended_projects.user_id,
    recommended_projects.category_id,
    recommended_projects.goal,
    recommended_projects.summary,
    recommended_projects.headline,
    recommended_projects.video_url,
    recommended_projects.short_url,
    recommended_projects.created_at,
    recommended_projects.updated_at,
    recommended_projects.summary_html,
    recommended_projects.recommended,
    recommended_projects.home_page_comment,
    recommended_projects.permalink,
    recommended_projects.video_thumbnail,
    recommended_projects.state,
    recommended_projects.online_days,
    recommended_projects.online_date,
    recommended_projects.how_know,
    recommended_projects.more_urls,
    recommended_projects.first_contributions,
    recommended_projects.uploaded_image,
    recommended_projects.video_embed_url,
    recommended_projects.budget,
    recommended_projects.budget_html,
    recommended_projects.terms,
    recommended_projects.terms_html,
    recommended_projects.site,
    recommended_projects.hash_tag,
    recommended_projects.address_city,
    recommended_projects.address_state,
    recommended_projects.address_zip_code,
    recommended_projects.address_neighborhood,
    recommended_projects.featured,
    recommended_projects.home_page,
    recommended_projects.summary_textile,
    recommended_projects.budget_textile,
    recommended_projects.terms_textile,
    recommended_projects.latitude,
    recommended_projects.longitude,
    recommended_projects.hero_image,
    recommended_projects.sent_to_analysis_at,
    recommended_projects.organization_type,
    recommended_projects.street_address,
    recommended_projects.credit_type,
    recommended_projects.minimum_investment,
    recommended_projects.rating,
    recommended_projects.rating_agency,
    recommended_projects.statement_file_url,
    recommended_projects.sale_date
   FROM recommended_projects
UNION
 SELECT expiring_projects.origin,
    expiring_projects.id,
    expiring_projects.name,
    expiring_projects.user_id,
    expiring_projects.category_id,
    expiring_projects.goal,
    expiring_projects.summary,
    expiring_projects.headline,
    expiring_projects.video_url,
    expiring_projects.short_url,
    expiring_projects.created_at,
    expiring_projects.updated_at,
    expiring_projects.summary_html,
    expiring_projects.recommended,
    expiring_projects.home_page_comment,
    expiring_projects.permalink,
    expiring_projects.video_thumbnail,
    expiring_projects.state,
    expiring_projects.online_days,
    expiring_projects.online_date,
    expiring_projects.how_know,
    expiring_projects.more_urls,
    expiring_projects.first_contributions,
    expiring_projects.uploaded_image,
    expiring_projects.video_embed_url,
    expiring_projects.budget,
    expiring_projects.budget_html,
    expiring_projects.terms,
    expiring_projects.terms_html,
    expiring_projects.site,
    expiring_projects.hash_tag,
    expiring_projects.address_city,
    expiring_projects.address_state,
    expiring_projects.address_zip_code,
    expiring_projects.address_neighborhood,
    expiring_projects.featured,
    expiring_projects.home_page,
    expiring_projects.summary_textile,
    expiring_projects.budget_textile,
    expiring_projects.terms_textile,
    expiring_projects.latitude,
    expiring_projects.longitude,
    expiring_projects.hero_image,
    expiring_projects.sent_to_analysis_at,
    expiring_projects.organization_type,
    expiring_projects.street_address,
    expiring_projects.credit_type,
    expiring_projects.minimum_investment,
    expiring_projects.rating,
    expiring_projects.rating_agency,
    expiring_projects.statement_file_url,
    expiring_projects.sale_date
   FROM expiring_projects
UNION
 SELECT soon_projects.origin,
    soon_projects.id,
    soon_projects.name,
    soon_projects.user_id,
    soon_projects.category_id,
    soon_projects.goal,
    soon_projects.summary,
    soon_projects.headline,
    soon_projects.video_url,
    soon_projects.short_url,
    soon_projects.created_at,
    soon_projects.updated_at,
    soon_projects.summary_html,
    soon_projects.recommended,
    soon_projects.home_page_comment,
    soon_projects.permalink,
    soon_projects.video_thumbnail,
    soon_projects.state,
    soon_projects.online_days,
    soon_projects.online_date,
    soon_projects.how_know,
    soon_projects.more_urls,
    soon_projects.first_contributions,
    soon_projects.uploaded_image,
    soon_projects.video_embed_url,
    soon_projects.budget,
    soon_projects.budget_html,
    soon_projects.terms,
    soon_projects.terms_html,
    soon_projects.site,
    soon_projects.hash_tag,
    soon_projects.address_city,
    soon_projects.address_state,
    soon_projects.address_zip_code,
    soon_projects.address_neighborhood,
    soon_projects.featured,
    soon_projects.home_page,
    soon_projects.summary_textile,
    soon_projects.budget_textile,
    soon_projects.terms_textile,
    soon_projects.latitude,
    soon_projects.longitude,
    soon_projects.hero_image,
    soon_projects.sent_to_analysis_at,
    soon_projects.organization_type,
    soon_projects.street_address,
    soon_projects.credit_type,
    soon_projects.minimum_investment,
    soon_projects.rating,
    soon_projects.rating_agency,
    soon_projects.statement_file_url,
    soon_projects.sale_date
   FROM soon_projects
UNION
 SELECT successful_projects.origin,
    successful_projects.id,
    successful_projects.name,
    successful_projects.user_id,
    successful_projects.category_id,
    successful_projects.goal,
    successful_projects.summary,
    successful_projects.headline,
    successful_projects.video_url,
    successful_projects.short_url,
    successful_projects.created_at,
    successful_projects.updated_at,
    successful_projects.summary_html,
    successful_projects.recommended,
    successful_projects.home_page_comment,
    successful_projects.permalink,
    successful_projects.video_thumbnail,
    successful_projects.state,
    successful_projects.online_days,
    successful_projects.online_date,
    successful_projects.how_know,
    successful_projects.more_urls,
    successful_projects.first_contributions,
    successful_projects.uploaded_image,
    successful_projects.video_embed_url,
    successful_projects.budget,
    successful_projects.budget_html,
    successful_projects.terms,
    successful_projects.terms_html,
    successful_projects.site,
    successful_projects.hash_tag,
    successful_projects.address_city,
    successful_projects.address_state,
    successful_projects.address_zip_code,
    successful_projects.address_neighborhood,
    successful_projects.featured,
    successful_projects.home_page,
    successful_projects.summary_textile,
    successful_projects.budget_textile,
    successful_projects.terms_textile,
    successful_projects.latitude,
    successful_projects.longitude,
    successful_projects.hero_image,
    successful_projects.sent_to_analysis_at,
    successful_projects.organization_type,
    successful_projects.street_address,
    successful_projects.credit_type,
    successful_projects.minimum_investment,
    successful_projects.rating,
    successful_projects.rating_agency,
    successful_projects.statement_file_url,
    successful_projects.sale_date
   FROM successful_projects;


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: recommendations; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW recommendations AS
 SELECT recommendations.user_id,
    recommendations.project_id,
    (sum(recommendations.count))::bigint AS count
   FROM ( SELECT b.user_id,
            recommendations_1.id AS project_id,
            count(DISTINCT recommenders.user_id) AS count
           FROM ((((contributions b
             JOIN projects p ON ((p.id = b.project_id)))
             JOIN contributions backers_same_projects ON ((p.id = backers_same_projects.project_id)))
             JOIN contributions recommenders ON ((recommenders.user_id = backers_same_projects.user_id)))
             JOIN projects recommendations_1 ON ((recommendations_1.id = recommenders.project_id)))
          WHERE ((((((((b.state)::text = 'confirmed'::text) AND ((backers_same_projects.state)::text = 'confirmed'::text)) AND ((recommenders.state)::text = 'confirmed'::text)) AND (b.user_id <> backers_same_projects.user_id)) AND (recommendations_1.id <> b.project_id)) AND ((recommendations_1.state)::text = 'online'::text)) AND (NOT (EXISTS ( SELECT true AS bool
                   FROM contributions b2
                  WHERE ((((b2.state)::text = 'confirmed'::text) AND (b2.user_id = b.user_id)) AND (b2.project_id = recommendations_1.id))))))
          GROUP BY b.user_id, recommendations_1.id
        UNION
         SELECT b.user_id,
            recommendations_1.id AS project_id,
            0 AS count
           FROM ((contributions b
             JOIN projects p ON ((b.project_id = p.id)))
             JOIN projects recommendations_1 ON ((recommendations_1.category_id = p.category_id)))
          WHERE (((b.state)::text = 'confirmed'::text) AND ((recommendations_1.state)::text = 'online'::text))) recommendations
  WHERE (NOT (EXISTS ( SELECT true AS bool
           FROM contributions b2
          WHERE ((((b2.state)::text = 'confirmed'::text) AND (b2.user_id = recommendations.user_id)) AND (b2.project_id = recommendations.project_id)))))
  GROUP BY recommendations.user_id, recommendations.project_id
  ORDER BY (sum(recommendations.count))::bigint DESC;


--
-- Name: rewards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rewards (
    id integer NOT NULL,
    project_id integer NOT NULL,
    maximum_contributions integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    row_order integer,
    happens_at date NOT NULL,
    principal_amount numeric,
    interest_rate numeric,
    yield numeric,
    price numeric,
    cusip_number character varying(255),
    CONSTRAINT rewards_maximum_backers_positive CHECK ((maximum_contributions >= 0))
);


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: routing_numbers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE routing_numbers (
    id integer NOT NULL,
    number character varying(255),
    bank_name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: routing_numbers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE routing_numbers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: routing_numbers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE routing_numbers_id_seq OWNED BY routing_numbers.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE states (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    acronym character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT states_acronym_not_blank CHECK ((length(btrim((acronym)::text)) > 0)),
    CONSTRAINT states_name_not_blank CHECK ((length(btrim((name)::text)) > 0))
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE states_id_seq OWNED BY states.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taggings (
    id integer NOT NULL,
    tag_id integer NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    visible boolean DEFAULT false
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: total_backed_ranges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE total_backed_ranges (
    name text NOT NULL,
    lower numeric,
    upper numeric
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email text,
    name text,
    nickname text,
    bio text,
    image_url text,
    newsletter boolean DEFAULT false,
    project_updates boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    admin boolean DEFAULT false,
    address_street text,
    address_number text,
    address_complement text,
    address_neighborhood text,
    address_city text,
    address_state text,
    address_zip_code text,
    phone_number text,
    locale text DEFAULT 'pt'::text NOT NULL,
    encrypted_password character varying(128) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    twitter_url character varying(255),
    facebook_url character varying(255),
    other_url character varying(255),
    uploaded_image text,
    state_inscription character varying(255),
    profile_type character varying(255),
    linkedin_url character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(255),
    new_project boolean DEFAULT false,
    latitude double precision,
    longitude double precision,
    completeness_progress integer DEFAULT 0,
    bonds_early_adopter boolean DEFAULT false NOT NULL,
    referrer_id integer,
    referral_code character varying(255),
    beta boolean DEFAULT false,
    access_code_id integer,
    CONSTRAINT users_bio_length_within CHECK (((length(bio) >= 0) AND (length(bio) <= 140)))
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: webhook_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE webhook_events (
    id integer NOT NULL,
    serialized_record hstore,
    kind character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: webhook_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE webhook_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhook_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE webhook_events_id_seq OWNED BY webhook_events.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY access_codes ALTER COLUMN id SET DEFAULT nextval('access_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY activities ALTER COLUMN id SET DEFAULT nextval('activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_access_tokens ALTER COLUMN id SET DEFAULT nextval('api_access_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations ALTER COLUMN id SET DEFAULT nextval('authorizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY balanced_contributors ALTER COLUMN id SET DEFAULT nextval('balanced_contributors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY brokerage_accounts ALTER COLUMN id SET DEFAULT nextval('brokerage_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts ALTER COLUMN id SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contributions ALTER COLUMN id SET DEFAULT nextval('contributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY images ALTER COLUMN id SET DEFAULT nextval('images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY investment_prospects ALTER COLUMN id SET DEFAULT nextval('investment_prospects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY neighborly_balanced_orders ALTER COLUMN id SET DEFAULT nextval('neighborly_balanced_orders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_providers ALTER COLUMN id SET DEFAULT nextval('oauth_providers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_notifications ALTER COLUMN id SET DEFAULT nextval('payment_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY press_assets ALTER COLUMN id SET DEFAULT nextval('press_assets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_documents ALTER COLUMN id SET DEFAULT nextval('project_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_faqs ALTER COLUMN id SET DEFAULT nextval('project_faqs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_totals ALTER COLUMN id SET DEFAULT nextval('project_totals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY routing_numbers ALTER COLUMN id SET DEFAULT nextval('routing_numbers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY states ALTER COLUMN id SET DEFAULT nextval('states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY webhook_events ALTER COLUMN id SET DEFAULT nextval('webhook_events_id_seq'::regclass);


--
-- Name: access_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY access_codes
    ADD CONSTRAINT access_codes_pkey PRIMARY KEY (id);


--
-- Name: activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: api_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY api_access_tokens
    ADD CONSTRAINT api_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: authorizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT authorizations_pkey PRIMARY KEY (id);


--
-- Name: backers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contributions
    ADD CONSTRAINT backers_pkey PRIMARY KEY (id);


--
-- Name: balanced_contributors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY balanced_contributors
    ADD CONSTRAINT balanced_contributors_pkey PRIMARY KEY (id);


--
-- Name: brokerage_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brokerage_accounts
    ADD CONSTRAINT brokerage_accounts_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: company_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT company_contacts_pkey PRIMARY KEY (id);


--
-- Name: images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: investment_prospects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY investment_prospects
    ADD CONSTRAINT investment_prospects_pkey PRIMARY KEY (id);


--
-- Name: neighborly_balanced_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY neighborly_balanced_orders
    ADD CONSTRAINT neighborly_balanced_orders_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oauth_providers_name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_providers
    ADD CONSTRAINT oauth_providers_name_unique UNIQUE (name);


--
-- Name: oauth_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_providers
    ADD CONSTRAINT oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: payment_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payment_notifications
    ADD CONSTRAINT payment_notifications_pkey PRIMARY KEY (id);


--
-- Name: press_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY press_assets
    ADD CONSTRAINT press_assets_pkey PRIMARY KEY (id);


--
-- Name: project_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_documents
    ADD CONSTRAINT project_documents_pkey PRIMARY KEY (id);


--
-- Name: project_faqs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_faqs
    ADD CONSTRAINT project_faqs_pkey PRIMARY KEY (id);


--
-- Name: project_totals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_totals
    ADD CONSTRAINT project_totals_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: routing_numbers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY routing_numbers
    ADD CONSTRAINT routing_numbers_pkey PRIMARY KEY (id);


--
-- Name: states_acronym_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_acronym_unique UNIQUE (acronym);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: total_backed_ranges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY total_backed_ranges
    ADD CONSTRAINT total_backed_ranges_pkey PRIMARY KEY (name);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webhook_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY webhook_events
    ADD CONSTRAINT webhook_events_pkey PRIMARY KEY (id);


--
-- Name: fk__activities_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__activities_project_id ON activities USING btree (project_id);


--
-- Name: fk__activities_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__activities_user_id ON activities USING btree (user_id);


--
-- Name: fk__api_access_tokens_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__api_access_tokens_user_id ON api_access_tokens USING btree (user_id);


--
-- Name: fk__authorizations_oauth_provider_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__authorizations_oauth_provider_id ON authorizations USING btree (oauth_provider_id);


--
-- Name: fk__authorizations_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__authorizations_user_id ON authorizations USING btree (user_id);


--
-- Name: fk__balanced_contributors_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__balanced_contributors_user_id ON balanced_contributors USING btree (user_id);


--
-- Name: fk__brokerage_accounts_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__brokerage_accounts_user_id ON brokerage_accounts USING btree (user_id);


--
-- Name: fk__images_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__images_user_id ON images USING btree (user_id);


--
-- Name: fk__investment_prospects_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__investment_prospects_user_id ON investment_prospects USING btree (user_id);


--
-- Name: fk__neighborly_balanced_orders_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__neighborly_balanced_orders_project_id ON neighborly_balanced_orders USING btree (project_id);


--
-- Name: fk__notifications_company_contact_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__notifications_company_contact_id ON notifications USING btree (contact_id);


--
-- Name: fk__organizations_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__organizations_user_id ON organizations USING btree (user_id);


--
-- Name: fk__project_documents_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__project_documents_project_id ON project_documents USING btree (project_id);


--
-- Name: fk__project_faqs_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__project_faqs_project_id ON project_faqs USING btree (project_id);


--
-- Name: fk__project_totals_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__project_totals_project_id ON project_totals USING btree (project_id);


--
-- Name: fk__taggings_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__taggings_project_id ON taggings USING btree (project_id);


--
-- Name: fk__taggings_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__taggings_tag_id ON taggings USING btree (tag_id);


--
-- Name: fk__users_access_code_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__users_access_code_id ON users USING btree (access_code_id);


--
-- Name: fk__users_referrer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__users_referrer_id ON users USING btree (referrer_id);


--
-- Name: index_activities_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activities_on_project_id ON activities USING btree (project_id);


--
-- Name: index_activities_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activities_on_user_id ON activities USING btree (user_id);


--
-- Name: index_api_access_tokens_on_expired; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_api_access_tokens_on_expired ON api_access_tokens USING btree (expired);


--
-- Name: index_api_access_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_api_access_tokens_on_user_id ON api_access_tokens USING btree (user_id);


--
-- Name: index_authorizations_on_oauth_provider_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_authorizations_on_oauth_provider_id_and_user_id ON authorizations USING btree (oauth_provider_id, user_id);


--
-- Name: index_authorizations_on_uid_and_oauth_provider_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_authorizations_on_uid_and_oauth_provider_id ON authorizations USING btree (uid, oauth_provider_id);


--
-- Name: index_balanced_contributors_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_balanced_contributors_on_user_id ON balanced_contributors USING btree (user_id);


--
-- Name: index_brokerage_accounts_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_brokerage_accounts_on_user_id ON brokerage_accounts USING btree (user_id);


--
-- Name: index_contributions_on_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contributions_on_key ON contributions USING btree (key);


--
-- Name: index_contributions_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contributions_on_project_id ON contributions USING btree (project_id);


--
-- Name: index_contributions_on_reward_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contributions_on_reward_id ON contributions USING btree (reward_id);


--
-- Name: index_contributions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contributions_on_user_id ON contributions USING btree (user_id);


--
-- Name: index_images_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_images_on_user_id ON images USING btree (user_id);


--
-- Name: index_investment_prospects_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_investment_prospects_on_user_id ON investment_prospects USING btree (user_id);


--
-- Name: index_neighborly_balanced_orders_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_neighborly_balanced_orders_on_project_id ON neighborly_balanced_orders USING btree (project_id);


--
-- Name: index_organizations_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_organizations_on_user_id ON organizations USING btree (user_id);


--
-- Name: index_payment_notifications_on_contribution_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payment_notifications_on_contribution_id ON payment_notifications USING btree (contribution_id);


--
-- Name: index_project_documents_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_documents_on_project_id ON project_documents USING btree (project_id);


--
-- Name: index_project_faqs_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_faqs_on_project_id ON project_faqs USING btree (project_id);


--
-- Name: index_project_totals_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_totals_on_project_id ON project_totals USING btree (project_id);


--
-- Name: index_projects_on_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_category_id ON projects USING btree (category_id);


--
-- Name: index_projects_on_latitude_and_longitude; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_latitude_and_longitude ON projects USING btree (latitude, longitude);


--
-- Name: index_projects_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_name ON projects USING btree (name);


--
-- Name: index_projects_on_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_projects_on_permalink ON projects USING btree (permalink);


--
-- Name: index_projects_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_user_id ON projects USING btree (user_id);


--
-- Name: index_rewards_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rewards_on_project_id ON rewards USING btree (project_id);


--
-- Name: index_taggings_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_project_id ON taggings USING btree (project_id);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_latitude_and_longitude; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_latitude_and_longitude ON users USING btree (latitude, longitude);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_name ON users USING btree (name);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE RULE "_RETURN" AS
    ON SELECT TO funding_raised_per_project_reports DO INSTEAD  SELECT project.id AS project_id,
    project.name AS project_name,
    sum(contributions.value) AS total_raised,
    count(*) AS total_backs,
    count(DISTINCT contributions.user_id) AS total_backers
   FROM (contributions
     JOIN projects project ON ((project.id = contributions.project_id)))
  WHERE ((contributions.state)::text <> ALL (ARRAY[('waiting_confirmation'::character varying)::text, ('pending'::character varying)::text, ('canceled'::character varying)::text, 'deleted'::text]))
  GROUP BY project.id;


--
-- Name: prevent_deletion_of_recommendations; Type: RULE; Schema: public; Owner: -
--

CREATE RULE prevent_deletion_of_recommendations AS
    ON DELETE TO recommendations DO INSTEAD NOTHING;


--
-- Name: contributions_project_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contributions
    ADD CONSTRAINT contributions_project_id_reference FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: contributions_reward_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contributions
    ADD CONSTRAINT contributions_reward_id_reference FOREIGN KEY (reward_id) REFERENCES rewards(id);


--
-- Name: contributions_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contributions
    ADD CONSTRAINT contributions_user_id_reference FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_activities_project_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT fk_activities_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_activities_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT fk_activities_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_api_access_tokens_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_access_tokens
    ADD CONSTRAINT fk_api_access_tokens_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_authorizations_oauth_provider_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT fk_authorizations_oauth_provider_id FOREIGN KEY (oauth_provider_id) REFERENCES oauth_providers(id) ON DELETE CASCADE;


--
-- Name: fk_authorizations_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT fk_authorizations_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_balanced_contributors_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY balanced_contributors
    ADD CONSTRAINT fk_balanced_contributors_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_brokerage_accounts_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY brokerage_accounts
    ADD CONSTRAINT fk_brokerage_accounts_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_images_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY images
    ADD CONSTRAINT fk_images_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_investment_prospects_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investment_prospects
    ADD CONSTRAINT fk_investment_prospects_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_neighborly_balanced_orders_project_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY neighborly_balanced_orders
    ADD CONSTRAINT fk_neighborly_balanced_orders_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_notifications_company_contact_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT fk_notifications_company_contact_id FOREIGN KEY (contact_id) REFERENCES contacts(id);


--
-- Name: fk_organizations_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT fk_organizations_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_project_documents_project_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_documents
    ADD CONSTRAINT fk_project_documents_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_project_faqs_project_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_faqs
    ADD CONSTRAINT fk_project_faqs_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_project_totals_project_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_totals
    ADD CONSTRAINT fk_project_totals_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_taggings_project_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT fk_taggings_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_taggings_tag_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT fk_taggings_tag_id FOREIGN KEY (tag_id) REFERENCES tags(id);


--
-- Name: fk_users_access_code_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_users_access_code_id FOREIGN KEY (access_code_id) REFERENCES access_codes(id);


--
-- Name: fk_users_referrer_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_users_referrer_id FOREIGN KEY (referrer_id) REFERENCES users(id);


--
-- Name: notifications_backer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_backer_id_fk FOREIGN KEY (contribution_id) REFERENCES contributions(id);


--
-- Name: notifications_project_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_project_id_reference FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: notifications_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_user_id_reference FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: payment_notifications_backer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_notifications
    ADD CONSTRAINT payment_notifications_backer_id_fk FOREIGN KEY (contribution_id) REFERENCES contributions(id);


--
-- Name: projects_category_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_category_id_reference FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: projects_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_user_id_reference FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: rewards_project_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_project_id_reference FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO public, pg_catalog;

INSERT INTO schema_migrations (version) VALUES ('20121226120921');

INSERT INTO schema_migrations (version) VALUES ('20121227012003');

INSERT INTO schema_migrations (version) VALUES ('20121227012324');

INSERT INTO schema_migrations (version) VALUES ('20121230111351');

INSERT INTO schema_migrations (version) VALUES ('20130102180139');

INSERT INTO schema_migrations (version) VALUES ('20130104005632');

INSERT INTO schema_migrations (version) VALUES ('20130104104501');

INSERT INTO schema_migrations (version) VALUES ('20130105123546');

INSERT INTO schema_migrations (version) VALUES ('20130110191750');

INSERT INTO schema_migrations (version) VALUES ('20130117205659');

INSERT INTO schema_migrations (version) VALUES ('20130118193907');

INSERT INTO schema_migrations (version) VALUES ('20130121162447');

INSERT INTO schema_migrations (version) VALUES ('20130121204224');

INSERT INTO schema_migrations (version) VALUES ('20130121212325');

INSERT INTO schema_migrations (version) VALUES ('20130131121553');

INSERT INTO schema_migrations (version) VALUES ('20130201200604');

INSERT INTO schema_migrations (version) VALUES ('20130201202648');

INSERT INTO schema_migrations (version) VALUES ('20130201202829');

INSERT INTO schema_migrations (version) VALUES ('20130201205659');

INSERT INTO schema_migrations (version) VALUES ('20130204192704');

INSERT INTO schema_migrations (version) VALUES ('20130205143533');

INSERT INTO schema_migrations (version) VALUES ('20130206121758');

INSERT INTO schema_migrations (version) VALUES ('20130211174609');

INSERT INTO schema_migrations (version) VALUES ('20130212145115');

INSERT INTO schema_migrations (version) VALUES ('20130213184141');

INSERT INTO schema_migrations (version) VALUES ('20130218201312');

INSERT INTO schema_migrations (version) VALUES ('20130218201751');

INSERT INTO schema_migrations (version) VALUES ('20130221171018');

INSERT INTO schema_migrations (version) VALUES ('20130221172840');

INSERT INTO schema_migrations (version) VALUES ('20130221175717');

INSERT INTO schema_migrations (version) VALUES ('20130221184144');

INSERT INTO schema_migrations (version) VALUES ('20130221185532');

INSERT INTO schema_migrations (version) VALUES ('20130221201732');

INSERT INTO schema_migrations (version) VALUES ('20130222163633');

INSERT INTO schema_migrations (version) VALUES ('20130225135512');

INSERT INTO schema_migrations (version) VALUES ('20130225141802');

INSERT INTO schema_migrations (version) VALUES ('20130228141234');

INSERT INTO schema_migrations (version) VALUES ('20130304193806');

INSERT INTO schema_migrations (version) VALUES ('20130307074614');

INSERT INTO schema_migrations (version) VALUES ('20130307090153');

INSERT INTO schema_migrations (version) VALUES ('20130308200907');

INSERT INTO schema_migrations (version) VALUES ('20130311191444');

INSERT INTO schema_migrations (version) VALUES ('20130311192846');

INSERT INTO schema_migrations (version) VALUES ('20130312001021');

INSERT INTO schema_migrations (version) VALUES ('20130313032607');

INSERT INTO schema_migrations (version) VALUES ('20130313034356');

INSERT INTO schema_migrations (version) VALUES ('20130319131919');

INSERT INTO schema_migrations (version) VALUES ('20130410181958');

INSERT INTO schema_migrations (version) VALUES ('20130410190247');

INSERT INTO schema_migrations (version) VALUES ('20130410191240');

INSERT INTO schema_migrations (version) VALUES ('20130411193016');

INSERT INTO schema_migrations (version) VALUES ('20130419184530');

INSERT INTO schema_migrations (version) VALUES ('20130422071805');

INSERT INTO schema_migrations (version) VALUES ('20130422072051');

INSERT INTO schema_migrations (version) VALUES ('20130423162359');

INSERT INTO schema_migrations (version) VALUES ('20130424173128');

INSERT INTO schema_migrations (version) VALUES ('20130426204503');

INSERT INTO schema_migrations (version) VALUES ('20130429142823');

INSERT INTO schema_migrations (version) VALUES ('20130429144749');

INSERT INTO schema_migrations (version) VALUES ('20130429153115');

INSERT INTO schema_migrations (version) VALUES ('20130430203333');

INSERT INTO schema_migrations (version) VALUES ('20130502175814');

INSERT INTO schema_migrations (version) VALUES ('20130505013655');

INSERT INTO schema_migrations (version) VALUES ('20130506191243');

INSERT INTO schema_migrations (version) VALUES ('20130506191508');

INSERT INTO schema_migrations (version) VALUES ('20130514132519');

INSERT INTO schema_migrations (version) VALUES ('20130514185010');

INSERT INTO schema_migrations (version) VALUES ('20130514185116');

INSERT INTO schema_migrations (version) VALUES ('20130514185926');

INSERT INTO schema_migrations (version) VALUES ('20130515192404');

INSERT INTO schema_migrations (version) VALUES ('20130523144013');

INSERT INTO schema_migrations (version) VALUES ('20130523173609');

INSERT INTO schema_migrations (version) VALUES ('20130527204639');

INSERT INTO schema_migrations (version) VALUES ('20130529171845');

INSERT INTO schema_migrations (version) VALUES ('20130604171730');

INSERT INTO schema_migrations (version) VALUES ('20130604172253');

INSERT INTO schema_migrations (version) VALUES ('20130604175953');

INSERT INTO schema_migrations (version) VALUES ('20130604180503');

INSERT INTO schema_migrations (version) VALUES ('20130607222330');

INSERT INTO schema_migrations (version) VALUES ('20130617175402');

INSERT INTO schema_migrations (version) VALUES ('20130618175432');

INSERT INTO schema_migrations (version) VALUES ('20130626122439');

INSERT INTO schema_migrations (version) VALUES ('20130626124055');

INSERT INTO schema_migrations (version) VALUES ('20130702192659');

INSERT INTO schema_migrations (version) VALUES ('20130703171547');

INSERT INTO schema_migrations (version) VALUES ('20130705131825');

INSERT INTO schema_migrations (version) VALUES ('20130705184845');

INSERT INTO schema_migrations (version) VALUES ('20130710122804');

INSERT INTO schema_migrations (version) VALUES ('20130722222945');

INSERT INTO schema_migrations (version) VALUES ('20130730232043');

INSERT INTO schema_migrations (version) VALUES ('20130805230126');

INSERT INTO schema_migrations (version) VALUES ('20130812191450');

INSERT INTO schema_migrations (version) VALUES ('20130814174329');

INSERT INTO schema_migrations (version) VALUES ('20130815161926');

INSERT INTO schema_migrations (version) VALUES ('20130818015857');

INSERT INTO schema_migrations (version) VALUES ('20130819184232');

INSERT INTO schema_migrations (version) VALUES ('20130819204154');

INSERT INTO schema_migrations (version) VALUES ('20130819223216');

INSERT INTO schema_migrations (version) VALUES ('20130820110933');

INSERT INTO schema_migrations (version) VALUES ('20130820154632');

INSERT INTO schema_migrations (version) VALUES ('20130820161734');

INSERT INTO schema_migrations (version) VALUES ('20130820162240');

INSERT INTO schema_migrations (version) VALUES ('20130820170244');

INSERT INTO schema_migrations (version) VALUES ('20130820191030');

INSERT INTO schema_migrations (version) VALUES ('20130820192708');

INSERT INTO schema_migrations (version) VALUES ('20130820203742');

INSERT INTO schema_migrations (version) VALUES ('20130820221456');

INSERT INTO schema_migrations (version) VALUES ('20130820230214');

INSERT INTO schema_migrations (version) VALUES ('20130821150626');

INSERT INTO schema_migrations (version) VALUES ('20130821155342');

INSERT INTO schema_migrations (version) VALUES ('20130821155425');

INSERT INTO schema_migrations (version) VALUES ('20130821161021');

INSERT INTO schema_migrations (version) VALUES ('20130822050311');

INSERT INTO schema_migrations (version) VALUES ('20130822215532');

INSERT INTO schema_migrations (version) VALUES ('20130827184633');

INSERT INTO schema_migrations (version) VALUES ('20130827210414');

INSERT INTO schema_migrations (version) VALUES ('20130827220135');

INSERT INTO schema_migrations (version) VALUES ('20130828160026');

INSERT INTO schema_migrations (version) VALUES ('20130828174723');

INSERT INTO schema_migrations (version) VALUES ('20130829180232');

INSERT INTO schema_migrations (version) VALUES ('20130829221342');

INSERT INTO schema_migrations (version) VALUES ('20130902180813');

INSERT INTO schema_migrations (version) VALUES ('20130905153553');

INSERT INTO schema_migrations (version) VALUES ('20130911180657');

INSERT INTO schema_migrations (version) VALUES ('20130917192958');

INSERT INTO schema_migrations (version) VALUES ('20130917194540');

INSERT INTO schema_migrations (version) VALUES ('20130918191809');

INSERT INTO schema_migrations (version) VALUES ('20130924171524');

INSERT INTO schema_migrations (version) VALUES ('20130924224115');

INSERT INTO schema_migrations (version) VALUES ('20130925164743');

INSERT INTO schema_migrations (version) VALUES ('20130925191707');

INSERT INTO schema_migrations (version) VALUES ('20130925200737');

INSERT INTO schema_migrations (version) VALUES ('20130926185207');

INSERT INTO schema_migrations (version) VALUES ('20130930203850');

INSERT INTO schema_migrations (version) VALUES ('20131001202019');

INSERT INTO schema_migrations (version) VALUES ('20131008190648');

INSERT INTO schema_migrations (version) VALUES ('20131010193936');

INSERT INTO schema_migrations (version) VALUES ('20131010194006');

INSERT INTO schema_migrations (version) VALUES ('20131010194345');

INSERT INTO schema_migrations (version) VALUES ('20131010194500');

INSERT INTO schema_migrations (version) VALUES ('20131010194521');

INSERT INTO schema_migrations (version) VALUES ('20131014201229');

INSERT INTO schema_migrations (version) VALUES ('20131016193346');

INSERT INTO schema_migrations (version) VALUES ('20131016214955');

INSERT INTO schema_migrations (version) VALUES ('20131016231130');

INSERT INTO schema_migrations (version) VALUES ('20131018170211');

INSERT INTO schema_migrations (version) VALUES ('20131020215932');

INSERT INTO schema_migrations (version) VALUES ('20131021190108');

INSERT INTO schema_migrations (version) VALUES ('20131022154220');

INSERT INTO schema_migrations (version) VALUES ('20131023031539');

INSERT INTO schema_migrations (version) VALUES ('20131023032325');

INSERT INTO schema_migrations (version) VALUES ('20131107143439');

INSERT INTO schema_migrations (version) VALUES ('20131107143512');

INSERT INTO schema_migrations (version) VALUES ('20131107143537');

INSERT INTO schema_migrations (version) VALUES ('20131107143832');

INSERT INTO schema_migrations (version) VALUES ('20131107145351');

INSERT INTO schema_migrations (version) VALUES ('20131107161918');

INSERT INTO schema_migrations (version) VALUES ('20131107235621');

INSERT INTO schema_migrations (version) VALUES ('20131108011509');

INSERT INTO schema_migrations (version) VALUES ('20131112113608');

INSERT INTO schema_migrations (version) VALUES ('20131113145601');

INSERT INTO schema_migrations (version) VALUES ('20131114154112');

INSERT INTO schema_migrations (version) VALUES ('20131115161618');

INSERT INTO schema_migrations (version) VALUES ('20131115161712');

INSERT INTO schema_migrations (version) VALUES ('20131127132159');

INSERT INTO schema_migrations (version) VALUES ('20131203165406');

INSERT INTO schema_migrations (version) VALUES ('20131212220606');

INSERT INTO schema_migrations (version) VALUES ('20131221202026');

INSERT INTO schema_migrations (version) VALUES ('20131223211811');

INSERT INTO schema_migrations (version) VALUES ('20131224200147');

INSERT INTO schema_migrations (version) VALUES ('20131224210745');

INSERT INTO schema_migrations (version) VALUES ('20131224211151');

INSERT INTO schema_migrations (version) VALUES ('20131226220339');

INSERT INTO schema_migrations (version) VALUES ('20131226230842');

INSERT INTO schema_migrations (version) VALUES ('20131226231159');

INSERT INTO schema_migrations (version) VALUES ('20131227170938');

INSERT INTO schema_migrations (version) VALUES ('20140108165433');

INSERT INTO schema_migrations (version) VALUES ('20140108203826');

INSERT INTO schema_migrations (version) VALUES ('20140120195335');

INSERT INTO schema_migrations (version) VALUES ('20140120201216');

INSERT INTO schema_migrations (version) VALUES ('20140121114718');

INSERT INTO schema_migrations (version) VALUES ('20140121124230');

INSERT INTO schema_migrations (version) VALUES ('20140121124646');

INSERT INTO schema_migrations (version) VALUES ('20140121124840');

INSERT INTO schema_migrations (version) VALUES ('20140121125256');

INSERT INTO schema_migrations (version) VALUES ('20140121130341');

INSERT INTO schema_migrations (version) VALUES ('20140121171044');

INSERT INTO schema_migrations (version) VALUES ('20140121193929');

INSERT INTO schema_migrations (version) VALUES ('20140122165752');

INSERT INTO schema_migrations (version) VALUES ('20140128121507');

INSERT INTO schema_migrations (version) VALUES ('20140128122208');

INSERT INTO schema_migrations (version) VALUES ('20140130223126');

INSERT INTO schema_migrations (version) VALUES ('20140204131059');

INSERT INTO schema_migrations (version) VALUES ('20140210233516');

INSERT INTO schema_migrations (version) VALUES ('20140211184505');

INSERT INTO schema_migrations (version) VALUES ('20140212180711');

INSERT INTO schema_migrations (version) VALUES ('20140218181118');

INSERT INTO schema_migrations (version) VALUES ('20140220195747');

INSERT INTO schema_migrations (version) VALUES ('20140221000612');

INSERT INTO schema_migrations (version) VALUES ('20140221000924');

INSERT INTO schema_migrations (version) VALUES ('20140221023714');

INSERT INTO schema_migrations (version) VALUES ('20140221171650');

INSERT INTO schema_migrations (version) VALUES ('20140226191212');

INSERT INTO schema_migrations (version) VALUES ('20140228034409');

INSERT INTO schema_migrations (version) VALUES ('20140314202354');

INSERT INTO schema_migrations (version) VALUES ('20140324180104');

INSERT INTO schema_migrations (version) VALUES ('20140325123915');

INSERT INTO schema_migrations (version) VALUES ('20140328010428');

INSERT INTO schema_migrations (version) VALUES ('20140328120740');

INSERT INTO schema_migrations (version) VALUES ('20140401180011');

INSERT INTO schema_migrations (version) VALUES ('20140401181046');

INSERT INTO schema_migrations (version) VALUES ('20140403173849');

INSERT INTO schema_migrations (version) VALUES ('20140409195932');

INSERT INTO schema_migrations (version) VALUES ('20140410130510');

INSERT INTO schema_migrations (version) VALUES ('20140410200741');

INSERT INTO schema_migrations (version) VALUES ('20140411140737');

INSERT INTO schema_migrations (version) VALUES ('20140411153421');

INSERT INTO schema_migrations (version) VALUES ('20140415170308');

INSERT INTO schema_migrations (version) VALUES ('20140416171749');

INSERT INTO schema_migrations (version) VALUES ('20140423182227');

INSERT INTO schema_migrations (version) VALUES ('20140506164815');

INSERT INTO schema_migrations (version) VALUES ('20140506171311');

INSERT INTO schema_migrations (version) VALUES ('20140507191030');

INSERT INTO schema_migrations (version) VALUES ('20140509123001');

INSERT INTO schema_migrations (version) VALUES ('20140515185046');

INSERT INTO schema_migrations (version) VALUES ('20140516135956');

INSERT INTO schema_migrations (version) VALUES ('20140516181346');

INSERT INTO schema_migrations (version) VALUES ('20140527200930');

INSERT INTO schema_migrations (version) VALUES ('20140530224700');

INSERT INTO schema_migrations (version) VALUES ('20140530225038');

INSERT INTO schema_migrations (version) VALUES ('20140612230821');

INSERT INTO schema_migrations (version) VALUES ('20140626141415');

INSERT INTO schema_migrations (version) VALUES ('20140708123838');

INSERT INTO schema_migrations (version) VALUES ('20140721232244');

INSERT INTO schema_migrations (version) VALUES ('20140801185200');

INSERT INTO schema_migrations (version) VALUES ('20140806134524');

INSERT INTO schema_migrations (version) VALUES ('20140806135608');

INSERT INTO schema_migrations (version) VALUES ('20140806141600');

INSERT INTO schema_migrations (version) VALUES ('20140807215229');

INSERT INTO schema_migrations (version) VALUES ('20140808185831');

INSERT INTO schema_migrations (version) VALUES ('20140814170158');

INSERT INTO schema_migrations (version) VALUES ('20140815171319');

INSERT INTO schema_migrations (version) VALUES ('20140816212033');

INSERT INTO schema_migrations (version) VALUES ('20140822150920');

INSERT INTO schema_migrations (version) VALUES ('20140827181425');

INSERT INTO schema_migrations (version) VALUES ('20140829195912');

INSERT INTO schema_migrations (version) VALUES ('20140909220324');

INSERT INTO schema_migrations (version) VALUES ('20140912162610');

INSERT INTO schema_migrations (version) VALUES ('20140912221643');

INSERT INTO schema_migrations (version) VALUES ('20140912225658');

INSERT INTO schema_migrations (version) VALUES ('20140915205939');

INSERT INTO schema_migrations (version) VALUES ('20140916165622');

INSERT INTO schema_migrations (version) VALUES ('20140918210041');

INSERT INTO schema_migrations (version) VALUES ('20140919192329');

INSERT INTO schema_migrations (version) VALUES ('20140922183239');

INSERT INTO schema_migrations (version) VALUES ('20140924204913');

INSERT INTO schema_migrations (version) VALUES ('20140925165552');

INSERT INTO schema_migrations (version) VALUES ('20140925225445');

INSERT INTO schema_migrations (version) VALUES ('20140930163732');

INSERT INTO schema_migrations (version) VALUES ('20140930202758');

INSERT INTO schema_migrations (version) VALUES ('20141001162251');

INSERT INTO schema_migrations (version) VALUES ('20141001184613');

INSERT INTO schema_migrations (version) VALUES ('20141002000613');

INSERT INTO schema_migrations (version) VALUES ('20141002145006');

INSERT INTO schema_migrations (version) VALUES ('20141002194215');

INSERT INTO schema_migrations (version) VALUES ('20141002211059');

INSERT INTO schema_migrations (version) VALUES ('20141005171546');

INSERT INTO schema_migrations (version) VALUES ('20141005185320');

INSERT INTO schema_migrations (version) VALUES ('20141005191635');

INSERT INTO schema_migrations (version) VALUES ('20141007210436');

INSERT INTO schema_migrations (version) VALUES ('20141009230817');

INSERT INTO schema_migrations (version) VALUES ('20141009231956');

INSERT INTO schema_migrations (version) VALUES ('20141009232040');

INSERT INTO schema_migrations (version) VALUES ('20141010020350');

INSERT INTO schema_migrations (version) VALUES ('20141015002044');

INSERT INTO schema_migrations (version) VALUES ('20141015003808');

INSERT INTO schema_migrations (version) VALUES ('20141017233122');

INSERT INTO schema_migrations (version) VALUES ('20141019175915');

INSERT INTO schema_migrations (version) VALUES ('20141019192913');

