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
  const dM = distance(point(first), point(last), { units: "meters" });
  return dM <= maxDistanceM;
};

export const calculateTotalDistanceMeters = (coords: Coordinate[]): number => {
  if (!Array.isArray(coords) || coords.length < 2) return 0;
  let totalM = 0;
  for (let i = 1; i < coords.length; i += 1) {
    const prev = coords[i - 1]!;
    const curr = coords[i]!;
    const dM = distance(point(prev), point(curr), { units: "meters" });
    totalM += dM;
  }
  return totalM;
};

export const cleanDuplicates = (coords: Coordinate[], eps = 0): Coordinate[] => {
  const out: Coordinate[] = [];
  for (const c of coords) {
    const last = out[out.length - 1];
    if (!last) out.push(c);
    else {
      const same = eps === 0
        ? (last[0] === c[0] && last[1] === c[1])
        : (Math.abs(last[0] - c[0]) <= eps && Math.abs(last[1] - c[1]) <= eps);
      if (!same) out.push(c);
    }
  }
  return out;
};

export const isValidLineString = (coords: Coordinate[]): boolean =>
  Array.isArray(coords) && coords.length >= 2;

export const isValidPolygon = (ring: Coordinate[]): boolean => {
  // minimum 4 points with closure (first == last)
  if (!Array.isArray(ring) || ring.length < 4) return false;
  const a = ring[0]!;
  const b = ring[ring.length - 1]!;
  return a[0] === b[0] && a[1] === b[1];
};

export default {
  calculatePolygonAreaMeters2,
  isPolygonClosedWithinMeters,
  calculateTotalDistanceMeters,
  cleanDuplicates,
  isValidLineString,
  isValidPolygon,
};
