#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS postgis;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE TABLE "public"."aoi" (
    "name" varchar(500) COLLATE "pg_catalog"."default" NOT NULL,
    "geom" geometry(GEOMETRY) NOT NULL
  );
  ALTER TABLE "public"."aoi"
    OWNER TO "postgres";
  CREATE INDEX "geom" ON "public"."aoi" USING btree (
    "geom" "public"."btree_geometry_ops" ASC NULLS LAST
  );
  CREATE INDEX "name" ON "public"."aoi" USING btree (
    "name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
  );
  CREATE INDEX "name_geom" ON "public"."aoi" USING btree (
    "name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
    "geom" "public"."btree_geometry_ops" ASC NULLS LAST
  );
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE TABLE "public"."poi" (
    "name" varchar(500) COLLATE "pg_catalog"."default" NOT NULL,
    "geom" geometry(GEOMETRY) NOT NULL
  );
  ALTER TABLE "public"."poi"
    OWNER TO "postgres";
  CREATE INDEX "geom_copy1" ON "public"."poi" USING btree (
    "geom" "public"."btree_geometry_ops" ASC NULLS LAST
  );
  CREATE INDEX "name_copy1" ON "public"."poi" USING btree (
    "name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
  );
  CREATE INDEX "name_geom_copy1" ON "public"."poi" USING btree (
    "name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
    "geom" "public"."btree_geometry_ops" ASC NULLS LAST
  );
EOSQL
