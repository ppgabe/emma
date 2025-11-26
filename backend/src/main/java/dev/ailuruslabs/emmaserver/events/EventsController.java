package dev.ailuruslabs.emmaserver.events;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.awt.*;

@RestController
@RequestMapping("/api/events")
class EventsController {

    private final ServerSentEventsService serverSentEventsService;

    EventsController(ServerSentEventsService serverSentEventsService) {this.serverSentEventsService = serverSentEventsService;}

    @GetMapping(path = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter stream() {
        return serverSentEventsService.subscribe();
    }
}
