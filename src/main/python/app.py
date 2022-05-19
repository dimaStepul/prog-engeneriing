# encoding: UTF-8
import argparse
import json

# Веб сервер
import cherrypy

# Драйвер PostgreSQL
import psycopg2 as pg_driver
from peewee import *

import handlers
import models
from connect import connection_factory


class App:
    def __init__(self):
        self.route = Routes()
        self.schedule = Schedule()
        self.staff = Staff()
        self.fares = Fares()

    @cherrypy.expose(["/"])
    def index(self):
        cherrypy.response.headers["Content-Type"] = "text/plain; charset=utf-8"
        hello_message = """Привет! Посети:
        - /routes/info[?route=:route_id:] чтоб получить описание доступных маршрутов;
        - /schedule/info?route=:route_id:[&weekend=[true|false]] чтоб получить расписание определенного маршрута;
        - /staff/workload чтоб получить информацию о суммарном количестве смен, отработанных каждым водителем.
        - /fares/stats чтоб получить количество купленных билетов.
        """
        return hello_message.encode("utf-8")


class Routes:
    @cherrypy.expose
    @cherrypy.tools.json_out()
    def info(self, route=None):
        routes = models.Routes().info(route)
        return handlers.route_handler(routes, route)


class Schedule:
    @cherrypy.expose
    @cherrypy.tools.json_out()
    def info(self, route=None, weekend="false"):
        trips = models.Schedule().info(route, weekend)
        return handlers.schedule_handler(trips, route, weekend)


class Staff:
    @cherrypy.expose
    @cherrypy.tools.json_out()
    def workload(self, id=None):
        query = models.Staff().workload(id)
        return handlers.workload_handler(query)


class Fares:
    @cherrypy.expose
    @cherrypy.tools.json_out()
    def stats(self):
        query = models.Fares.stats(self)
        return handlers.stats_handler(query)


def error_page_404(status, message, traceback, version):
    cherrypy.response.headers["Content-Type"] = "text/plain"
    return f"ERROR {status}!"


def error_page_400(status, message, traceback, version):
    cherrypy.response.headers["Content-Type"] = "text/plain"
    return f"ERROR {status}\n{message}"


if __name__ == "__main__":
    cherrypy.config.update({'error_page.404': error_page_404})
    cherrypy.config.update({'error_page.400': error_page_400})
    cherrypy.quickstart(App())
