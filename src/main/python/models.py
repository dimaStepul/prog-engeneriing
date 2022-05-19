import cherrypy
from peewee import *

from connect import connection_factory, db


class Routes:
    def info(self, route=None):
        if (route is not None) and (not route.isdigit()):
            raise cherrypy.HTTPError(
                400,
                f"\nBad value of the integer parameter 'value': '{route}'"
                "\nFor routes available, see: /route/info",
            )

        cur = db.cursor()
        query_template = """
        SELECT r.id, r.transport_type, start.address, start.id, finish.address, finish.id
        FROM route r
        JOIN stop start ON start.id=r.first_stop_id
        JOIN stop finish ON finish.id=r.last_stop_id
        """

        if route is None:
            cur.execute(query_template)
        else:
            cur.execute(query_template + "WHERE r.id = %s", (route,))

        routes = cur.fetchall()
        return routes


class Schedule:
    def info(self, route=None, weekend="false"):
        if route is None:
            raise cherrypy.HTTPError(
                400,
                "\nPlease, specify route: /?route=:route:"
                "\nFor routes available, see: /route/info",
            )
        elif not route.isdigit():
            raise cherrypy.HTTPError(
                400,
                f"\nBad value of the integer parameter 'value': '{route}'"
                "\nFor routes available, see: /route/info",
            )
        if weekend not in ["true", "false"]:
            raise cherrypy.HTTPError(
                400,
                f"\nBad value of the boolean parameter 'weekend': '{weekend}'"
                "\nUse 'true' or 'false'",
            )
        cur = db.cursor()
        query_template = """
        WITH relevant_routes AS (
            SELECT t.arrival_time, start.address, start.id, finish.address, finish.id
            FROM timetable t
            JOIN route r ON r.id=t.route_id
            JOIN stop start ON start.id=r.first_stop_id
            JOIN stop finish ON finish.id=r.last_stop_id
            WHERE r.id = %s and weekend = %s
        )

        SELECT * FROM relevant_routes
        WHERE arrival_time = (SELECT MIN(arrival_time) FROM relevant_routes)
            OR arrival_time = (SELECT MAX(arrival_time) FROM relevant_routes)
        ORDER BY arrival_time
        """
        cur.execute(query_template, (route, weekend))
        trips = cur.fetchall()
        return trips


class StaffEntity(Model):
    name = CharField()
    surname = CharField()
    patronymic = CharField()
    id = IntegerField()
    shift_count = IntegerField()

    class Meta:
        database = db
        table_name = "staffworkload"


class StaffModel:
    def __init__(self, entity):
        self.entity = entity
        self.id = entity.id

    def name(self):
        return self.entity.name

    def surname(self):
        return self.entity.surname

    def patronymic(self):
        return self.entity.patronymic

    def id(self):
        return self.entity.id

    def shift_count(self):
        return self.entity.shift_count


class Staff:
    def workload(self, id):
        q = StaffEntity.select()
        if id is not None:
            q = q.where(StaffEntity.id == id)
        return q


class FaresEntity(Model):
    id = AutoField()
    title = CharField()
    total_validations = IntegerField()
    total_price_sum = IntegerField()

    class Meta:
        database = db
        table_name = "faresstats"


class Fares:
    def stats(self):
        q = FaresEntity.select()
        return q
