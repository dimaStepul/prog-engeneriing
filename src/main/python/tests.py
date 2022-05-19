import unittest

import models
import handlers


class RouteTest:
    def __init__(
        self,
        id,
        transport,
        start_adress,
        start_stop_num,
        finish_adress,
        finish_stop_num,
    ):
        self.id = id
        self.transporte = transport
        self.start_adress = start_adress
        self.start_stop_num = start_stop_num
        self.finish_adress = finish_adress
        self.finish_stop_num = finish_stop_num

    def transport(self):
        return self.transport

    def start_adress(self):
        return self.start_adress

    def start_stop_num(self):
        return self.start_stop_num()

    def finish_adress(self):
        return self.finish_adress()

    def finish_stop_num(self):
        return self.finish_stop_num


class TestWebApp(unittest.TestCase):
    def test_route(self):
        def all_route():
            return [RouteTest(1, "Автобус", "1-я линия ВО", 147, "Елецкая улица", 181)]

        routes = models.Routes().info("1")
        result = handlers.route_handler(routes)
        self.assertEqual("1-я линия ВО", result[0]["start"].get("address"))
        self.assertEqual("Елецкая улица", result[0]["finish"].get("address"))
        self.assertEqual("Автобус", result[0]["rolling_stock_type"])

        routes = models.Routes().info("13")
        result = handlers.route_handler(routes)
        self.assertEqual("улица Ленина 44", result[0]["start"].get("address"))
        self.assertEqual("Херсонская д.2", result[0]["finish"].get("address"))
        self.assertEqual(193, result[0]["finish"].get("stop_num"))
        self.assertEqual("Автобус", result[0]["rolling_stock_type"])

        routes = models.Routes().info("20")
        result = handlers.route_handler(routes)
        self.assertEqual("музей Эрарта", result[0]["start"].get("address"))
        self.assertEqual(155, result[0]["start"].get("stop_num"))
        self.assertEqual("станция метро Чкаловская", result[0]["finish"].get("address"))
        self.assertEqual(180, result[0]["finish"].get("stop_num"))
        self.assertEqual("Троллейбус", result[0]["rolling_stock_type"])

    def test_schedule(self):
        schedule = models.Schedule().info("12")
        result = handlers.schedule_handler(schedule, "12")
        self.assertEqual("06:49", result["first_trip_start"])
        self.assertEqual("15:40", result["last_trip_start"])
        self.assertEqual("улица Ленина 44", result["stops"][0].get("address"))
        self.assertEqual("Ашан", result["stops"][1].get("address"))


if __name__ == "__main__":
    unittest.main()
