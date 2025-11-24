package dev.ailuruslabs.emmaserver.incidents;

import jakarta.validation.Valid;
import org.springframework.stereotype.Service;

@Service
public class IncidentService {

    private final IncidentRepository incidentRepository;

    IncidentService(IncidentRepository incidentRepository) {this.incidentRepository = incidentRepository;}

    public Incident saveIncident(@Valid IncidentCreateRequest incidentCreateRequest) {
        // save incident to repo here
        // empty for now
        return new Incident();
    }
}
