package dev.ailuruslabs.emmaserver.incidents;

import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class IncidentService {

    private final IncidentRepository incidentRepository;
    private final GeometryFactory geometryFactory;

    IncidentService(IncidentRepository incidentRepository, GeometryFactory geometryFactory) {
        this.incidentRepository = incidentRepository;
        this.geometryFactory = geometryFactory;
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
                incidentReportRequest.coordinates().longitude(),
                incidentReportRequest.coordinates().latitude()
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
