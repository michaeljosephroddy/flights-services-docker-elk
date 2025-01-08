package com.tus.flight.controller;

import java.time.LocalDateTime;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.tomcat.util.http.HeaderUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tus.flight.model.Flight;
import com.tus.flight.repo.FlightRepository;

@RestController
public class FlightController {

	@Autowired
	FlightRepository repo;

	private static final Logger logger = LoggerFactory.getLogger(FlightController.class);

	@GetMapping("/flights")
	public List<Flight> getFlights(HttpServletRequest request, HttpServletResponse response) {
		String logString = String.format("method=%s, path=%s, status=%s", request.getMethod(), request.getRequestURI(),
				response.getStatus());
		logger.info(logString);
		return repo.findAll();

	}

}
