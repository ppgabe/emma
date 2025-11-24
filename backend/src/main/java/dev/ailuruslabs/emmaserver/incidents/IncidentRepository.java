package dev.ailuruslabs.emmaserver.incidents;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
interface IncidentRepository extends JpaRepository<Incident, Long> {
}
