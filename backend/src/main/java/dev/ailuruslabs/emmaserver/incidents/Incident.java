package dev.ailuruslabs.emmaserver.incidents;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.locationtech.jts.geom.Point;

import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
public class Incident {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private UUID reporterId;

    @Column(columnDefinition = "geography(Point, 4326)")
    private Point location;

    private String title;
    private String description;

    @Enumerated(EnumType.STRING)
    private IncidentType type;

    @CreationTimestamp
    @Column(updatable = false)
    private ZonedDateTime reportedAt;

    private ZonedDateTime updatedAt;
}
