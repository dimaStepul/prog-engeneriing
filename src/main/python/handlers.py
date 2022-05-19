import cherrypy

from models import StaffEntity, StaffModel


def route_handler(routes, route=None):
    results = [
        {
            "route": r[0],
            "rolling_stock_type": r[1],
            "start": {"address": r[2], "stop_num": r[3]},
            "finish": {"address": r[4], "stop_num": r[5]},
        }
        for r in routes
    ]
    if not results:
        raise cherrypy.HTTPError(
            400,
            f"\nCan not find such route: '{route}'"
            "\nFor routes available, see: /route/info",
        )
    return results


def schedule_handler(trips, route=None, weekend="false"):
    if not trips:
        raise cherrypy.HTTPError(
            400,
            f"\nCan not find such route on {'weekends' if weekend == 'true' else 'weekdays'}: '{route}'"
            "\nFor routes available, see: /route/info.",
        )
    else:
        first_trip, last_trip = trips
        results = {
            "route": route,
            "first_trip_start": first_trip[0].strftime("%H:%M"),
            "last_trip_start": last_trip[0].strftime("%H:%M"),
            "stops": [
                {"address": first_trip[1], "stop_num": first_trip[2]},
                {"address": first_trip[3], "stop_num": first_trip[4]},
            ],
        }
    return results


def workload_handler(query):
    return list(
        map(
            lambda p: {
                "id": p.id,
                "name": p.surname() + " " + p.name() + " " + p.patronymic(),
                "shift_count": p.shift_count(),
            },
            [StaffModel(p) for p in query],
        )
    )


def stats_handler(query):
    results = [
        {
            "title": p.title,
            "total_validations": p.total_validations,
            "total_price_sum": p.total_price_sum,
        }
        for p in query
    ]
    # ensure_ascii=False, чтобы работал русский
    return results
