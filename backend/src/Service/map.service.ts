import DistrictModel from "../Models/district.model.js";

class MapServiceClass {
  public async findDistrictByCoordinates(latitude: number, longitude: number) {
    const district = await DistrictModel.findOne({
      geometry: {
        $geoIntersects: {
          $geometry: {
            type: "Point",
            coordinates: [longitude, latitude],
          },
        },
      },
    }).select("name");

    return district;
  }
}

const MapService = new MapServiceClass();
export default MapService;
