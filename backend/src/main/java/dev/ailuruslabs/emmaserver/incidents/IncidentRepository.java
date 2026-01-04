package dev.ailuruslabs.emmaserver.incidents;

import org.locationtech.jts.geom.Point;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
interface IncidentRepository extends JpaRepository<Incident, Long> {

    @Query(value = """
        SELECT * FROM incidents
        WHERE ST_DWithin(location, :userLocation, :radiusInMeters)
        ORDER BY incidents.updated_at DESC
        """, nativeQuery = true)
    List<Incident> findWithinRadius(
        @Param("userLocation") Point userLocation,
        @Param("radiusInMeters") double radiusInMeters
    );

    @Query(value = """
        SELECT * FROM incidents
        WHERE ST_Intersects(
            location,
            ST_MakeEnvelope(
                :#{#topLeftPoint.lon()},
                :#{#bottomRightPoint.lat()},
                :#{#bottomRightPoint.lon()},
                :#{#topLeftPoint.lat()},
                4326
            )
        )
        ORDER BY incidents.updated_at DESC
        """, nativeQuery = true)
    List<Incident> findWithinBounds(
        @Param("topLeftPoint") Coordinates topLeftPoint,
        @Param("bottomRightPoint") Coordinates bottomRightPoint
    );
}
