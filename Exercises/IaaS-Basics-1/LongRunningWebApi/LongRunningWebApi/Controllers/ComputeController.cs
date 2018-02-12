using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Results;

namespace LongRunningWebApi.Controllers
{
    public class ComputeController : ApiController
    {

        // GET api/compute/5
        public JsonResult<string[]> Get(int id)
        {
            string[] values = new string[3];
            values[0] = System.Environment.MachineName;

            var start = DateTime.UtcNow;
            values[1] = GetValueOfLongRunningComputation(id).ToString();
            var end = DateTime.UtcNow;
            values[2] = (end - start).TotalMilliseconds.ToString() + " milliseconds";
            return Json(values);
        }

        private int GetValueOfLongRunningComputation(int id)
        {
            if (id < 1)
            {
                return -1;
            }
            if (id < 3)
            {
                return 1;
            }
            else
            {
                return GetValueOfLongRunningComputation(id - 1) + GetValueOfLongRunningComputation(id - 2);
            }

        }
    }
}
