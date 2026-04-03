import { Type, Platform, EntityProperty, ValidationError } from '@mikro-orm/core';

export interface Point {
  latitude: number;
  longitude: number;
}

/**
 * Custom MikroORM type for PostGIS geography(Point, 4326).
 * Stores lat/lng as a PostGIS point, enables ST_DWithin queries.
 */
export class PointType extends Type<Point | undefined, string | undefined> {
  convertToDatabaseValue(
    value: Point | undefined,
    platform: Platform,
  ): string | undefined {
    if (!value) return undefined;

    if (
      typeof value.latitude !== 'number' ||
      typeof value.longitude !== 'number' ||
      value.latitude < -90 ||
      value.latitude > 90 ||
      value.longitude < -180 ||
      value.longitude > 180
    ) {
      throw ValidationError.invalidType(PointType, value, 'JS');
    }

    return `SRID=4326;POINT(${value.longitude} ${value.latitude})`;
  }

  convertToJSValue(value: string | undefined): Point | undefined {
    if (!value) return undefined;

    // Handle GeoJSON format from PostGIS: {"type":"Point","coordinates":[lng,lat]}
    if (typeof value === 'object') {
      const geo = value as unknown as { coordinates: [number, number] };
      return { longitude: geo.coordinates[0], latitude: geo.coordinates[1] };
    }

    // Handle EWKT format: SRID=4326;POINT(lng lat)
    const match = value.match(/POINT\(([^ ]+) ([^ ]+)\)/);
    if (match) {
      return { longitude: parseFloat(match[1]), latitude: parseFloat(match[2]) };
    }

    return undefined;
  }

  convertToJSValueSQL(key: string): string {
    return `ST_AsGeoJSON(${key})::jsonb`;
  }

  convertToDatabaseValueSQL(key: string): string {
    return `ST_GeogFromText(${key})`;
  }

  getColumnType(prop: EntityProperty, platform: Platform): string {
    return 'geography(Point, 4326)';
  }
}
