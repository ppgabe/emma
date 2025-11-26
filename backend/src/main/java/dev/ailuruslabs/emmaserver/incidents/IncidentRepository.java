package dev.ailuruslabs.emmaserver.incidents;

import org.locationtech.jts.geom.Point;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
interface IncidentRepository extends JpaRepository<Incident, Long> {

    @Query("SELECT i FROM Incident i WHERE ST_DWithin(i.location, :userLocation, :radiusInMeters) = true")
    List<Incident> findNearbyWithinRadius(
        @Param("userLocation") Point userLocation,
        @Param("radiusInMeters") double radiusInMeters
    );
}
