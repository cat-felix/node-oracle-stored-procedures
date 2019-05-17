const o_oradb	= require("oracledb");
const u = require("./api-utils.js");

/*****************************************************************************/
module.exports = {
	ora_exec_prc: function (dbc, prn, prm, out) {
		return new Promise(async(resolve, reject)=>{
			let vrs = Object.keys(prm), len = vrs.length, res = null;
			let sql_txt = (prn.indexOf(".")!=-1)?"begin "+prn+"(":"begin api_front."+prn+"(";
			for (let i=0; i<len; i++) {sql_txt += ":"+vrs[i]; sql_txt += (i<len-1)?",":"";}
			sql_txt += "); end;";
		 	dbc.execute(sql_txt, prm, (e, o_res)=>{
    		if (e && e.errorNum) {
					out.code = e.errorNum;
					out.text = e.message;
					u._trace(u.f_ora_log, arguments.callee.name+": "+e.message, prm);
				} else {
					res = (typeof o_res != "undefined" && typeof o_res.outBinds != "undefined")?o_res.outBinds:{};
				}
				resolve(res);
			});
		});
	},
	ora_exec_im: function (dbc, cfg, out) {
		return new Promise(async(resolve, reject)=>{
			let tms = new Date().getTime();
			let prm = {
			  msg_id: {type: o_oradb.NUMBER, dir: o_oradb.BIND_OUT},
			  msg_name: cfg.name, 
				msg_email: cfg.email, 
				msg_phone: cfg.phone,
				msg_value: cfg.message,
			  result: {type: o_oradb.NUMBER, dir: o_oradb.BIND_OUT}
			}
			let prs = await this.ora_exec_prc(dbc, "InsertMessage", prm, out);
			if (u.checkIsObject(prs)) {
  			out.code = prs.result;
				out.time = new Date().getTime()-tms;
				switch (prs.result) {
					case 0: /* Success */
						out.data = prs.msg_id;
					break;
					case 1:
						out.text = "Please, inter your name";
					break;
					case 2:
						out.text = "Please, inter your email";
					break;
					case 3:
						out.text = "Email is incorrect";
					break;
					case 4:
						out.text = "Please, inter your message";
					break;
					default:
						out.text = "Error on database side, see T_REPORT_LOG for details";
						u._trace(u.f_ora_log, arguments.callee.name+": -1", cfg);
					break
				}
			} else {
				u._trace(u.f_ora_log, arguments.callee.name+": unknown error, prs is not an object", cfg);
			}
			resolve();
		});
	},
};