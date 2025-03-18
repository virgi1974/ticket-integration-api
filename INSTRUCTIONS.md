# Personal Event API Integration Exercise

Welcome! This challenge is designed to strengthen my coding approach and problem-solving skills. It simulates real-world scenarios of integrating third-party data into a marketplace platform.

## Context

This exercise focuses on building a system that integrates events from external providers into a centralized marketplace. The goal is to expand the range of experiences offered by continuously integrating new providers with great events.

## The Challenge

The task is to develop a microservice that integrates events from an external provider into a marketplace platform.

Even as a personal exercise, I'll approach this as if someone will maintain this code in the future. It should be designed to evolve as new features are added, existing ones adapted, and unnecessary functionalities removed. Writing clean, scalable, and maintainable code is crucial for ensuring the sustainability of any project.

> [!TIP]
> This should be conceived as a long-term project, not just one-off code.

The external provider exposes an endpoint: https://sample-provider.example.com/api/events

This API returns a list of available events in XML format. Events that are no longer available will not be included in future responses. Here are three example responses over consecutive API calls:

- [Response 1](https://example.com/sample1.xml)
- [Response 2](https://example.com/sample2.xml)
- [Response 3](https://example.com/sample3.xml)

> [!WARNING]
> The API endpoint should be designed with real-world conditions in mind, where network requests don't always behave ideally. The solution should demonstrate how to handle various scenarios that could occur in production environments. **Don't assume the API endpoint will always respond successfully and with low latency.**

## Main Task

I need to **develop and expose a single endpoint**:

- The endpoint should accept `starts_at` and `ends_at` parameters and return only the events within this time range.
- Events should be included if they were ever available (with `"sell_mode": "online"`).
- Past events should be retrievable even if they are no longer present in the provider's latest response.
- The endpoint must be performant, responding in **hundreds of milliseconds**, regardless of the state of other external services. For instance, if the external provider service is down, our search endpoint should still work as usual. Similarly, it should also respond quickly to all requests regardless of the traffic received.

## Evaluation Points

For self-assessment, I'll focus on:

- **Problem-Solution Fit:** How well the solution aligns with the given problem.
- **Documentation:** Clear explanation of design choices and implementation details, with additional design schemas.
- **Makefile:** Including a Makefile with a run target to simplify running the application.
- **Code Quality:** Readability, maintainability, and adherence to best practices.
- **Software Architecture:** Structural design choices and scalability considerations.
- **Efficiency:** Optimization for both resources and time efficiency.

## Guidelines

- Use my preferred programming language (Ruby on Rails).
- Feel free to use any libraries, frameworks, or tools that best fit the task.

## Advanced Challenges 🚀

To make the solution even stronger, I'll consider:

- **Scalability:** How to handle a scenario where the provider sends thousands of events with hundreds of zones per event.
- **High Traffic:** How the service would respond to 5k-10k requests per second.
- **Optimization Strategies:** How the system can remain performant under heavy load.

I can implement these enhancements in the code or describe my approach in the README.

This exercise gives me a chance to practice real-world microservice development with an emphasis on reliability and performance.

## Need Help?

If you have any questions, feel free to reach out. I'll get back to you as soon as possible.

## Feedback

I value your time and effort! Please take a moment to share your thoughts on our process:

[📋 Feedback Form](https://forms.gle/6NdDApby6p3hHsWp8)

Thank you for participating, and good luck! 🎉
