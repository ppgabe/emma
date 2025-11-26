package dev.ailuruslabs.emmaserver.incidents;

import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class IncidentService {

    private final IncidentRepository incidentRepository;
    private final GeometryFactory geometryFactory;

    IncidentService(IncidentRepository incidentRepository, GeometryFactory geometryFactory) {
        this.incidentRepository = incidentRepository;
        this.geometryFactory = geometryFactory;
    }

    public Page<Incident> getIncidents(Pageable pageable) {
        return incidentRepository.findAll(pageable);
    }

    public List<Incident> getIncidentsWithinRadius(Coordinates userCoordinates, double radius) {
        var userLocation = geometryFactory.createPoint(
            new Coordinate(
                userCoordinates.lon(),
                userCoordinates.lat()
            )
        );

        return incidentRepository.findWithinRadius(userLocation, radius);
    }

    public List<Incident> getIncidentsWithinBounds(Coordinates topLeft, Coordinates bottomRight) {
        return incidentRepository.findWithinBounds(topLeft, bottomRight);
    }

    public Incident saveIncident(IncidentReportRequest incidentReportRequest) {
        var userPrincipal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        UUID userUUID;
        if (userPrincipal instanceof Jwt jwt) {
            try {
                userUUID = UUID.fromString(jwt.getSubject());
            } catch (IllegalArgumentException iae) {
                throw new JwtException("Invalid UUID in JWT");
            }
        } else throw new JwtException("Invalid JWT");

        var incidentPoint = geometryFactory.createPoint(
            new Coordinate(
                incidentReportRequest.coordinates().lon(),
                incidentReportRequest.coordinates().lat()
            )
        );

        return incidentRepository.save(
            new Incident(
                userUUID,
                incidentPoint,
                incidentReportRequest.title(),
                incidentReportRequest.description(),
                incidentReportRequest.type()
            )
        );
    }
}
