import area from "@turf/area";
import distance from "@turf/distance";
import { polygon, point } from "@turf/helpers";
type Coordinate = [number, number]; // [lng, lat]

type PolygonCoords = Coordinate[][]; // [ring][point]

const closeRing = (ring: Coordinate[]): Coordinate[] => {
  if (ring.length < 2) return ring;
  const [firstLng, firstLat] = ring[0]!;
  const [lastLng, lastLat] = ring[ring.length - 1]!;
  if (firstLng === lastLng && firstLat === lastLat) return ring;
  return [...ring, ring[0]!];
};

export const calculatePolygonAreaMeters2 = (polygonCoords: PolygonCoords): number => {
  if (!Array.isArray(polygonCoords) || polygonCoords.length === 0) return 0;

  const closedRings = polygonCoords.map(closeRing);
  const poly = polygon(closedRings);
  return area(poly);
};

export const isPolygonClosedWithinMeters = (
  ring: Coordinate[],
  maxDistanceM: number = 30,
): boolean => {
  if (!Array.isArray(ring) || ring.length < 3) return false;
  const first = ring[0]!;
  const last = ring[ring.length - 1]!;
  const dKm = distance(point(first), point(last), { units: "kilometers" });
  return dKm * 1000 <= maxDistanceM;
};

export default {
  calculatePolygonAreaMeters2,
  isPolygonClosedWithinMeters,
};
